use starknet::ContractAddress;

#[derive(Drop, Serde)]
pub struct Course {
    pub id: u256,
    pub title: felt252,
    pub description: felt252,
    pub price: u256,
    pub is_free: bool,
    pub tags: Array<felt252>,
    pub tutor: ContractAddress,
    pub enrolled_students: Array<ContractAddress>,
    pub completed_students: Array<ContractAddress>,
    pub created_at: u64,
    pub updated_at: u64,
}

#[derive(Drop, Serde)]
pub struct StudentCourses {
    pub enrolled_courses: Array<u256>,
    pub completed_courses: Array<u256>,
    pub nft_certificates: Array<u256>,
}

#[derive(Drop, Serde)]
pub struct TutorCourses {
    pub created_courses: Array<u256>,
    pub total_revenue: u256,
    pub available_revenue: u256,
}

#[derive(Drop, Serde)]
pub struct CourseMetadata {
    pub course_id: u256,
    pub course_title: felt252,
    pub completion_date: u64,
    pub student_address: ContractAddress,
    pub tutor_address: ContractAddress,
}
