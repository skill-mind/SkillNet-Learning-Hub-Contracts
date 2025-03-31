#[starknet::contract]
pub mod SkillNet {
    use starknet::storage::{
        Map, MutableVecTrait, StorageMapReadAccess, StorageMapWriteAccess, StoragePathEntry,
        StoragePointerReadAccess, StoragePointerWriteAccess, Vec, VecTrait,
    };
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};
    use crate::errors::{
        COURSE_IS_FREE, COURSE_NOT_FOUND, COURSE_NOT_COMPLETED, FEE_TRANSFER_FAILED,
        INSUFFICIENT_PAYMENT, NOT_COURSE_TUTOR, PAYMENT_FAILED, TUTOR_PAYMENT_FAILED,
        USER_ALREADY_ENROLLED,
    };
    use crate::interfaces::ISkillNet::ISkillNet;
    use crate::types::{Course, CourseMetadata, StudentCourses, TutorCourses};


    #[storage]
    struct Storage {
        // Contract addresses for component management
        admin: ContractAddress,
        nft_contract: ContractAddress,
        payment_contract: ContractAddress,
        skillnet_wallet: ContractAddress,
        // Protocol configuration parameters
        protocol_fee: u256, // Base points (1 = 0.01%)
        min_course_price: u256, // Minimum price for paid courses
        max_course_price: u256, // Maximum price for paid courses
        is_paused: bool, // Protocol pause state
        // Course management
        courses: Map<u256, Course>,
        next_course_id: u256,
        nuum: Map<u8, u8>,
        // User management
        students: Map<ContractAddress, StudentCourses>,
        tutors: Map<ContractAddress, TutorCourses>,
        // Protocol statistics
        total_courses: u256,
        active_courses: u256,
        total_students: u256,
        total_tutors: u256,
        total_revenue: u256,
        // students are mapped to the course_id of the Course they are taking
        enrollments: Map<ContractAddress, Map<u256, bool>>,
        completions: Map<ContractAddress, Map<u256, bool>>,
        course_tags: Map<u256, Array<felt252>>,
        balances: Map<ContractAddress, u256>,
    }


    #[constructor]
    fn constructor(
        ref self: ContractState,
        admin: ContractAddress,
        nft_contract: ContractAddress,
        payment_contract: ContractAddress,
        skillnet_wallet: ContractAddress,
    ) {
        // Store the values in contract state
        self.admin.write(admin);
        self.nft_contract.write(nft_contract);
        self.payment_contract.write(payment_contract);
        self.skillnet_wallet.write(skillnet_wallet);
    }


    #[abi(embed_v0)]
    impl SkillNetImpl of ISkillNet<ContractState> {
        /// @notice Creates a new course
        /// @dev Only the admin can create courses
        /// @param title The title of the course
        /// @param description A brief description of the course
        /// @param price The price of the course (0 if free)
        /// @param is_free A boolean indicating if the course is free
        /// @param tags A string representing tags/categories for the course
        /// @return course_id The unique ID of the created course
        fn create_course(
            ref self: ContractState,
            title: felt252,
            description: felt252,
            price: u256,
            is_free: bool,
            tags: felt252,
        ) -> u256 {
            // Ensure only the admin can create courses
            assert!(self.admin.read() == get_caller_address(), "Not Admin");

            // Validate input parameters
            assert!(title != 0, "Course title cannot be empty");
            assert!(description != 0, "Course description cannot be empty");

            let tutor = get_caller_address();
            let course_id = self.next_course_id.read();

            // If course is free, charge tutor a fixed fee
            if is_free {
                let free_course_fee = 100_u256; // Define your fixed fee for free courses
                let payment_success = self
                    .process_payment(tutor, self.skillnet_wallet.read(), free_course_fee);
                assert(payment_success, PAYMENT_FAILED);
                self.total_revenue.write(self.total_revenue.read() + free_course_fee);
            } else {
                assert!(price > 0, "Paid courses must have a price greater than zero");
            }

            let new_course = Course {
                id: course_id,
                title,
                description,
                price,
                is_free,
                tags,
                tutor: get_caller_address(),
                created_at: get_block_timestamp(),
                updated_at: get_block_timestamp(),
                students_id: 0,
            };

            // Store the course in the courses map
            self.courses.write(course_id, new_course);

            // Increment course ID and update storage **after** using it
            self.next_course_id.write(course_id + 1);
            self.total_courses.write(self.total_courses.read() + 1);

            course_id
        }


        fn get_course(self: @ContractState, course_id: u256) -> Course {
            // Retrieve and return the course
            let course = self.courses.read(course_id);

            course
        }


        fn update_course(
            ref self: ContractState,
            course_id: u256,
            title: felt252,
            description: felt252,
            price: u256,
            is_free: bool,
            tags: felt252,
        ) -> bool {
            true
        }

        // Student Management
        fn enroll_course(
            ref self: ContractState, course_id: u256, student: ContractAddress,
        ) -> bool {
            // Check if course exists
            assert(self.courses.read(course_id).id == course_id, COURSE_NOT_FOUND);

            // Check if student is already enrolled
            let is_enrolled = self.enrollments.entry(student).entry(course_id).read();
            assert(!is_enrolled, USER_ALREADY_ENROLLED);

            let mut course = self.courses.read(course_id);
            // PROCESS PAYMENT FOR PAID COURSES
            if !course.is_free {
                let payment_success = self.process_course_payment(course_id, student, course.price);
                assert(payment_success, PAYMENT_FAILED);
            }
            self.total_students.write(self.total_students.read() + 1);

            // Update course student count
            course.students_id += 1;
            self.courses.write(course_id, course);

            // Mark student as taking this course
            self.enrollments.entry(student).entry(course_id).write(true);

            true
        }

        fn complete_course(
            ref self: ContractState, course_id: u256, student: ContractAddress,
        ) -> bool {
            // Check if course exists
            assert(self.courses.read(course_id).id == course_id, COURSE_NOT_FOUND);

            // Check if student is enrolled in the course
            let is_enrolled = self.enrollments.entry(student).entry(course_id).read();
            assert(is_enrolled, 'Student not enrolled');

            // Mark the course as completed by the student
            self.completions.entry(student).entry(course_id).write(true);

            true
        }

        // fn get_student_courses(self: @ContractState, student: ContractAddress) -> StudentCourses{

        // }

        // // Tutor Management
        // fn get_tutor_courses(self: @ContractState, tutor: ContractAddress) -> TutorCourses{

        // }

        // fn get_tutor_revenue(self: @ContractState, tutor: ContractAddress) -> u256 {
        //     100
        // }

        // NFT Management
        fn mint_completion_nft(
            ref self: ContractState, course_id: u256, student: ContractAddress,
        ) -> u256 {
            79
        }

        /// @notice Allows a tutor to upload a certificate as an NFT for a student who completed
        /// their course @dev Only the course tutor can issue certificates for their own courses
        /// @param course_id The ID of the course the certificate is for
        /// @param student The address of the student receiving the certificate
        /// @param certificate_title The title to be displayed on the certificate
        /// @return token_id The unique ID of the minted NFT certificate
        fn upload_certificate_nft(
            ref self: ContractState,
            course_id: u256,
            student: ContractAddress,
            certificate_title: felt252,
        ) -> u256 {
            // Get the course from storage
            let course = self.courses.read(course_id);

            // Ensure the course exists
            assert(course.id == course_id, COURSE_NOT_FOUND);

            // Ensure the caller is the tutor of the course
            let caller = get_caller_address();
            assert(caller == course.tutor, NOT_COURSE_TUTOR);

            // Check if the student has completed the course
            let is_completed = self.completions.entry(student).entry(course_id).read();
            assert(is_completed, COURSE_NOT_COMPLETED);

            // Create certificate metadata
            let metadata = CourseMetadata {
                course_id,
                course_title: certificate_title,
                completion_date: get_block_timestamp(),
                student_address: student,
                tutor_address: caller,
            };

            // Mint the NFT certificate
            let token_id = self.mint(student, course_id, metadata);

            token_id
        }

        // fn get_student_nfts(self: @ContractState, student: ContractAddress) -> Array<u256>;

        // Payment Management
        fn process_course_payment(
            ref self: ContractState, course_id: u256, student: ContractAddress, amount: u256,
        ) -> bool {
            let course = self.courses.read(course_id);
            assert(course.id == course_id, COURSE_NOT_FOUND);
            assert(!course.is_free, COURSE_IS_FREE);
            assert(amount >= course.price, INSUFFICIENT_PAYMENT);

            // 10% protocol fee for paid courses (1000 basis points = 10%)
            let fee_amount = (amount * self.protocol_fee.read()) / 10000_u256;
            let tutor_amount = amount - fee_amount;

            let skillnet_wallet = self.skillnet_wallet.read();

            // Transfer 10% to protocol wallet
            let fee_success = self.process_payment(student, skillnet_wallet, fee_amount);
            assert(fee_success, FEE_TRANSFER_FAILED);

            // Transfer remainder to tutor
            let tutor_success = self.process_payment(student, course.tutor, tutor_amount);
            assert(tutor_success, TUTOR_PAYMENT_FAILED);

            self.total_revenue.write(self.total_revenue.read() + fee_amount);

            true
        }

        fn withdraw_tutor_revenue(
            ref self: ContractState, tutor: ContractAddress, amount: u256,
        ) -> bool {
            true
        }

        fn mint(
            ref self: ContractState, to: ContractAddress, course_id: u256, metadata: CourseMetadata,
        ) -> u256 {
            100
        }

        fn transfer(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256,
        ) -> bool {
            true
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            get_caller_address()
        }

        // fn get_metadata(self: @ContractState, token_id: u256) -> CourseMetadata;
        fn process_payment(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, amount: u256,
        ) -> bool {
            let from_balance = self.balances.read(from);
            assert(from_balance >= amount, 'Insufficient balance');
            let to_balance = self.balances.read(to);
            self.balances.write(from, from_balance - amount);
            self.balances.write(to, to_balance + amount);
            true
        }

        fn withdraw_funds(ref self: ContractState, account: ContractAddress, amount: u256) -> bool {
            true
        }

        fn deposit_funds(ref self: ContractState, account: ContractAddress, amount: u256) -> bool {
            // Get current balance
            let current_balance = self.balances.read(account);
            // Add amount to balance
            self.balances.write(account, current_balance + amount);
            true
        }

        fn get_balance(self: @ContractState, account: ContractAddress) -> u256 {
            let current_balance = self.balances.read(account);

            return current_balance;
        }

        fn get_admin(self: @ContractState) -> ContractAddress {
            self.admin.read()
        }

        fn get_nft_contract(self: @ContractState) -> ContractAddress {
            self.nft_contract.read()
        }

        fn get_payment_contract(self: @ContractState) -> ContractAddress {
            self.payment_contract.read()
        }

        fn get_skillnet_wallet(self: @ContractState) -> ContractAddress {
            self.skillnet_wallet.read()
        }
    }
}
