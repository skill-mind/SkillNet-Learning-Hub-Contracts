#[starknet::contract]
pub mod SkillNet {
    use starknet::storage::StorageMapWriteAccess;
    use starknet::storage::StorageMapReadAccess;
    use starknet::{
        ContractAddress, get_caller_address, get_block_timestamp, storage::Map,
        storage::StoragePointerWriteAccess, storage::StoragePointerReadAccess,
    };
    use crate::types::{Course, CourseMetadata, StudentCourses, TutorCourses};
    use crate::interfaces::ISkillNet::ISkillNet;


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
        students_taking_course: Map<ContractAddress, Map<u256, bool>>,
        students_completed_course: Map<ContractAddress, Map<u256, bool>>,
        course_tags: Map<u256, Array<felt252>>,
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
            assert!(
                self.admin.read() == get_caller_address(),
                "Not Admin",
            );
        
            // Validate input parameters
            assert!(title != 0, "Course title cannot be empty");
            assert!(description != 0, "Course description cannot be empty");
            assert!(is_free || price > 0, "Paid courses must have a price greater than zero");

        
            // Get the current course ID
            let course_id = self.next_course_id.read(); // Use it before incrementing
        
            // Create a new course struct
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
            true
        }

        fn complete_course(
            ref self: ContractState, course_id: u256, student: ContractAddress,
        ) -> bool {
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

        // fn get_student_nfts(self: @ContractState, student: ContractAddress) -> Array<u256>;

        // Payment Management
        fn process_course_payment(
            ref self: ContractState, course_id: u256, student: ContractAddress, amount: u256,
        ) -> bool {
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
            true
        }

        fn withdraw_funds(ref self: ContractState, account: ContractAddress, amount: u256) -> bool {
            true
        }

        fn get_balance(self: @ContractState, account: ContractAddress) -> u256 {
            5
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
