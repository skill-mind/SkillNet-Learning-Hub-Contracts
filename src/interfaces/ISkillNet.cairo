use starknet::ContractAddress;
use crate::types::{Course, CourseMetadata, StudentCourses, TutorCourses};

#[starknet::interface]
pub trait ISkillNet<TContractState> {
    // Course Management
    fn create_course(
        ref self: TContractState,
        title: felt252,
        description: felt252,
        price: u256,
        is_free: bool,
        tags: felt252,
    ) -> u256;

    fn get_course(self: @TContractState, course_id: u256) -> Course;

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
    fn enroll_course(ref self: TContractState, course_id: u256, student: ContractAddress) -> bool;

    fn complete_course(ref self: TContractState, course_id: u256, student: ContractAddress) -> bool;

    // fn get_student_courses(self: @TContractState, student: ContractAddress) -> StudentCourses;

    // Tutor Management
    // fn get_tutor_courses(self: @TContractState, tutor: ContractAddress) -> TutorCourses;

    // fn get_tutor_revenue(self: @TContractState, tutor: ContractAddress) -> u256;

    // NFT Management
    fn mint_completion_nft(
        ref self: TContractState, course_id: u256, student: ContractAddress,
    ) -> u256;
    
    fn upload_certificate_nft(
        ref self: TContractState, 
        course_id: u256, 
        student: ContractAddress, 
        certificate_title: felt252,
    ) -> u256;

    // fn get_student_nfts(self: @TContractState, student: ContractAddress) -> Array<u256>;

    fn mint(
        ref self: TContractState, to: ContractAddress, course_id: u256, metadata: CourseMetadata,
    ) -> u256;

    fn transfer(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256,
    ) -> bool;

    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;

    // fn get_metadata(self: @TContractState, token_id: u256) -> CourseMetadata;

    // Payment Management
    fn process_course_payment(
        ref self: TContractState, course_id: u256, student: ContractAddress, amount: u256,
    ) -> bool;

    fn withdraw_tutor_revenue(
        ref self: TContractState, tutor: ContractAddress, amount: u256,
    ) -> bool;

    fn process_payment(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, amount: u256,
    ) -> bool;

    fn withdraw_funds(ref self: TContractState, account: ContractAddress, amount: u256) -> bool;

    fn deposit_funds(ref self: TContractState, account: ContractAddress, amount: u256) -> bool;

    fn get_balance(self: @TContractState, account: ContractAddress) -> u256;

    // Platform Info
    fn get_admin(self: @TContractState) -> ContractAddress;

    fn get_nft_contract(self: @TContractState) -> ContractAddress;

    fn get_payment_contract(self: @TContractState) -> ContractAddress;

    fn get_skillnet_wallet(self: @TContractState) -> ContractAddress;
}
