use starknet::ContractAddress;
use starknet::storage::Vec;

/// @notice Struct containing all data for a single stream
#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct Course {
    pub id: u256,
    pub title: felt252,
    pub description: felt252,
    pub price: u256,
    pub is_free: bool,
    pub tags: felt252,
    pub tutor: ContractAddress,
    pub created_at: u64,
    pub updated_at: u64,
    pub students_id: u256,
}

#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct StudentCourses {
    pub enrolled_courses_count: u256,
    pub completed_courses_count: u256,
    pub nft_certificates_count: u256,
}

#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct TutorCourses {
    pub created_courses_count: u256,
    pub total_revenue: u256,
    pub available_revenue: u256,
}

#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct CourseMetadata {
    pub course_id: u256,
    pub course_title: felt252,
    pub completion_date: u64,
    pub student_address: ContractAddress,
    pub tutor_address: ContractAddress,
}

