/// Thrown when attempting to get a course that does not exist
pub const COURSE_NOT_FOUND: felt252 = 'Course not found';
/// Thrown when attempting to enroll to a course multiple times
pub const USER_ALREADY_ENROLLED: felt252 = 'User already enrolled';
/// Thrown when attempting to pay for a course
pub const PAYMENT_FAILED: felt252 = 'Payment processing failed';
/// Thrown when attempting to pay for a free course
pub const COURSE_IS_FREE: felt252 = 'Course is free';
/// Thrown when attempting to pay for a course
pub const INSUFFICIENT_PAYMENT: felt252 = 'Insufficient payment';
/// Thrown when attempting to pay for a course
pub const FEE_TRANSFER_FAILED: felt252 = 'Fee transfer failed';
/// Thrown when attempting to pay for a course
pub const TUTOR_PAYMENT_FAILED: felt252 = 'Tutor payment failed';
