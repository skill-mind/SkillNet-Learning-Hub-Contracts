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
/// Thrown when attempting to issue certificate for a course not completed by student
pub const COURSE_NOT_COMPLETED: felt252 = 'Course not completed by student';
/// Thrown when someone other than the course tutor tries to issue a certificate
pub const NOT_COURSE_TUTOR: felt252 = 'Not the course tutor';
/// Thrown when trying to complete a course while not enrolled
pub const STUDENT_NOT_ENROLLED: felt252 = 'Student not enrolled';
/// Thrown when attempting to transfer a token not owned by the sender
pub const NOT_TOKEN_OWNER: felt252 = 'Not token owner';
/// Thrown when attempting to transfer a token that doesn't exist in the sender's certificates
pub const TOKEN_NOT_FOUND: felt252 = 'Token not found';
