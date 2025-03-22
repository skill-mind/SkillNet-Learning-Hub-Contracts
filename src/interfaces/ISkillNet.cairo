use starknet::ContractAddress;
use crate::base::types::{Course, CourseMetadata, StudentCourses, TutorCourses};

#[starknet::interface]
pub trait ISkillNet<TContractState> {
    // Course Management
    /// Creates a new course.
    /// @param title The title of the course.
    /// @param description A brief description of the course.
    /// @param price The price of the course (0 if free).
    /// @param is_free Indicates if the course is free.
    /// @param tags Tags related to the course content.
    /// @return The newly created course ID.
    fn create_course(
        ref self: TContractState,
        title: felt252,
        description: felt252,
        price: u256,
        is_free: bool,
        tags: felt252,
    ) -> u256;

    /// Updates an existing course.
    /// @param course_id The ID of the course to update.
    /// @param title The new title of the course.
    /// @param description The updated description of the course.
    /// @param price The updated price of the course.
    /// @param is_free Indicates if the course is free.
    /// @param tags Updated tags for the course.
    /// @return True if the update is successful.
    fn update_course(
        ref self: TContractState,
        course_id: u256,
        title: felt252,
        description: felt252,
        price: u256,
        is_free: bool,
        tags: felt252,
    ) -> bool;

    // Student Management
    /// Enrolls a student in a course.
    /// @param course_id The ID of the course to enroll in.
    /// @param student The address of the student enrolling.
    /// @return True if enrollment is successful.
    fn enroll_course(ref self: TContractState, course_id: u256, student: ContractAddress) -> bool;

    /// Marks a course as completed for a student.
    /// @param course_id The ID of the completed course.
    /// @param student The address of the student.
    /// @return True if the completion is recorded successfully.
    fn complete_course(ref self: TContractState, course_id: u256, student: ContractAddress) -> bool;

    // Tutor Management
    /// Retrieves the total revenue earned by a tutor.
    /// @param tutor The address of the tutor.
    /// @return The total revenue amount.
    fn get_tutor_revenue(self: @TContractState, tutor: ContractAddress) -> u256;

    // NFT Management
    /// Mints a completion NFT for a student.
    /// @param course_id The ID of the completed course.
    /// @param student The address of the student receiving the NFT.
    /// @return The newly minted NFT ID.
    fn mint_completion_nft(
        ref self: TContractState, course_id: u256, student: ContractAddress,
    ) -> u256;

    // Payment Management
    /// Processes a course payment for a student.
    /// @param course_id The ID of the course.
    /// @param student The address of the student making the payment.
    /// @param amount The payment amount.
    /// @return True if payment is successful.
    fn process_course_payment(
        ref self: TContractState, course_id: u256, student: ContractAddress, amount: u256,
    ) -> bool;

    /// Allows a tutor to withdraw earned revenue.
    /// @param tutor The address of the tutor.
    /// @param amount The amount to withdraw.
    /// @return True if withdrawal is successful.
    fn withdraw_tutor_revenue(
        ref self: TContractState, tutor: ContractAddress, amount: u256,
    ) -> bool;

    /// Mints a course-related NFT to a specified address.
    /// @param to The recipient address.
    /// @param course_id The associated course ID.
    /// @param metadata Metadata related to the NFT.
    /// @return The newly minted NFT ID.
    fn mint(
        ref self: TContractState, to: ContractAddress, course_id: u256, metadata: CourseMetadata,
    ) -> u256;

    /// Transfers an NFT between addresses.
    /// @param from The sender's address.
    /// @param to The recipient's address.
    /// @param token_id The ID of the NFT being transferred.
    /// @return True if the transfer is successful.
    fn transfer(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256,
    ) -> bool;

    /// Retrieves the owner of a specific NFT.
    /// @param token_id The ID of the NFT.
    /// @return The address of the owner.
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;

    /// Processes a payment transaction between two addresses.
    /// @param from The sender's address.
    /// @param to The recipient's address.
    /// @param amount The transaction amount.
    /// @return True if the transaction is successful.
    fn process_payment(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, amount: u256,
    ) -> bool;

    /// Withdraws funds from an account.
    /// @param account The address of the account.
    /// @param amount The amount to withdraw.
    /// @return True if withdrawal is successful.
    fn withdraw_funds(ref self: TContractState, account: ContractAddress, amount: u256) -> bool;

    /// Retrieves the balance of a given account.
    /// @param account The address of the account.
    /// @return The current balance.
    fn get_balance(self: @TContractState, account: ContractAddress) -> u256;

    /// Retrieves the administrator's address.
    /// @return The admin's contract address.
    fn get_admin(self: @TContractState) -> ContractAddress;

    /// Retrieves the NFT contract address.
    /// @return The NFT contract address.
    fn get_nft_contract(self: @TContractState) -> ContractAddress;

    /// Retrieves the payment contract address.
    /// @return The payment contract address.
    fn get_payment_contract(self: @TContractState) -> ContractAddress;

    /// Retrieves the SkillNet platform wallet address.
    /// @return The SkillNet wallet address.
    fn get_skillnet_wallet(self: @TContractState) -> ContractAddress;

    fn get_course(self: @TContractState, course_id: u256) -> Course;
}
