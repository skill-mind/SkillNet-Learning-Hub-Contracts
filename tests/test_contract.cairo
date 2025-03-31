use skillnet_contract::interfaces::ISkillNet::{ISkillNetDispatcher, ISkillNetDispatcherTrait};
use snforge_std::{CheatSpan, ContractClassTrait, DeclareResultTrait, cheat_caller_address, declare};
use starknet::{ContractAddress, contract_address_const};


fn setup() -> (
    ContractAddress, ContractAddress, ContractAddress, ContractAddress, ContractAddress,
) {
    let admin_address: ContractAddress = contract_address_const::<'admin'>();
    let nft_contract: ContractAddress = contract_address_const::<'nft_contract'>();
    let payment_contract: ContractAddress = contract_address_const::<'payment_contract'>();
    let skillnet_wallet: ContractAddress = contract_address_const::<'skillnet_wallet'>();

    let declare_result = declare("SkillNet");
    assert(declare_result.is_ok(), 'Contract declaration failed');

    let contract_class = declare_result.unwrap().contract_class();
    let mut calldata = array![
        admin_address.into(), nft_contract.into(), payment_contract.into(), skillnet_wallet.into(),
    ];

    let deploy_result = contract_class.deploy(@calldata);
    assert(deploy_result.is_ok(), 'Contract deployment failed');

    let (contract_address, _) = deploy_result.unwrap();

    // ✅ Ensure we return the tuple correctly
    (contract_address, admin_address, nft_contract, payment_contract, skillnet_wallet)
}


// Function to store test values (if needed)
fn test_store(
    contract_address: ContractAddress,
    admin_address: ContractAddress,
    nft_contract: ContractAddress,
    payment_contract: ContractAddress,
    skillnet_wallet: ContractAddress,
) { // You can log or store these values if needed
}


#[test]
fn test_initial_data() {
    let (contract_address, admin_address, nft_contract, payment_contract, skillnet_wallet) =
        setup();

    let dispatcher = ISkillNetDispatcher { contract_address };

    // Ensure dispatcher methods exist
    let admin = dispatcher.get_admin();
    let nft = dispatcher.get_nft_contract();
    let payment = dispatcher.get_payment_contract();
    let skillnet = dispatcher.get_skillnet_wallet();

    assert(admin == admin_address, 'incorrect admin');
    assert(nft == nft_contract, 'incorrect nft');
    assert(payment == payment_contract, 'incorrect payment');
    assert(skillnet == skillnet_wallet, 'incorrect skillnet wallet');
}

#[test]
fn test_create_free_course_with_payment() {
    let (contract_address, admin_address, _, _, skillnet_wallet_address) = setup();
    let dispatcher = ISkillNetDispatcher { contract_address };

    let title: felt252 = 123456;
    let description: felt252 = 654321;
    let price: u256 = 0; // Free course
    let is_free: bool = true;
    let tags: felt252 = 789012;

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    // Deposit funds to tutor (admin)
    let deposit_amount = 1000_u256;
    dispatcher.deposit_funds(admin_address, deposit_amount);

    let initial_tutor_balance = dispatcher.get_balance(admin_address);
    let initial_skillnet_balance = dispatcher.get_balance(skillnet_wallet_address);

    let course_id = dispatcher.create_course(title, description, price, is_free, tags);

    let free_course_fee = 100_u256; // Match contract's fixed fee

    let final_tutor_balance = dispatcher.get_balance(admin_address);
    let final_skillnet_balance = dispatcher.get_balance(skillnet_wallet_address);

    assert(
        final_tutor_balance == initial_tutor_balance - free_course_fee, 'Tutor fee not deducted',
    );
    assert(
        final_skillnet_balance == initial_skillnet_balance + free_course_fee,
        'SkillNet fee not received',
    );

    let course = dispatcher.get_course(course_id);
    assert(course.is_free == true, 'Course should be free');
}


#[test]
#[should_panic]
fn test_fake_admin_set_data_fails() {
    let (contract_address, admin_address, _, _, _) = setup();
    let dispatcher = ISkillNetDispatcher { contract_address };

    // Test input values
    let title: felt252 = 123456; // Example felt252 value
    let description: felt252 = 654321; // Example felt252 value
    let price: u256 = 1000;
    let is_free: bool = false;
    let tags: felt252 = 789012; // Example felt252 value

    let admin: ContractAddress = contract_address_const::<'adminify'>();

    // Ensure the caller is the admin
    cheat_caller_address(contract_address, admin, CheatSpan::Indefinite);

    // Call create_course
    let course_id = dispatcher.create_course(title, description, price, is_free, tags);

    // Validate that the course ID is correctly incremented
    assert(course_id == 0, 'Course ID should start from 0');

    // Retrieve the course to verify it was stored correctly
    let course = dispatcher.get_course(course_id);
    assert(course.id == course_id, 'Course ID mismatch');
    assert(course.title == title, 'Course title mismatch');
    assert(course.description == description, 'Course description mismatch');
    assert(course.price == price, 'Course price mismatch');
    assert(course.is_free == is_free, 'Course is_free flag mismatch');
    assert(course.tags == tags, 'Course tags mismatch');
    assert(course.tutor == admin_address, 'Tutor address mismatch');
}
#[test]
fn test_create_multiple_courses() {
    let (contract_address, admin_address, _, _, _) = setup();
    let dispatcher = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    let first_id = dispatcher.create_course(123456, 654321, 1000, false, 789012);
    let second_id = dispatcher.create_course(223344, 554433, 2000, false, 998877);

    assert(first_id == 0, 'First course ID should be 0');
    assert(second_id == 1, 'Second course ID should be 1');

    let first_course = dispatcher.get_course(first_id);
    let second_course = dispatcher.get_course(second_id);

    assert(first_course.id == first_id, 'First course ID mismatch');
    assert(second_course.id == second_id, 'Second course ID mismatch');
}

#[test]
fn test_create_free_course() {
    let (contract_address, admin_address, _, _, _) = setup();
    let dispatcher = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    // Deposit funds to tutor
    dispatcher.deposit_funds(admin_address, 1000_u256);

    let course_id = dispatcher.create_course(123456, 654321, 0, true, 789012);

    let course = dispatcher.get_course(course_id);
    assert(course.is_free == true, 'Course should be free');
    assert(course.price == 0, 'Free course price should be 0');
}

#[test]
#[should_panic]
fn test_paid_course_with_zero_price_fails() {
    let (contract_address, admin_address, _, _, _) = setup();
    let dispatcher = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    dispatcher.create_course(123456, 654321, 0, false, 789012);
}

#[test]
#[should_panic]
fn test_create_course_with_empty_title_fails() {
    let (contract_address, admin_address, _, _, _) = setup();
    let dispatcher = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    dispatcher.create_course(0, 654321, 1000, false, 789012);
}

#[test]
#[should_panic]
fn test_create_course_with_empty_description_fails() {
    let (contract_address, admin_address, _, _, _) = setup();
    let dispatcher = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    dispatcher.create_course(123456, 0, 1000, false, 789012);
}

#[test]
fn test_course_data_persistence() {
    let (contract_address, admin_address, _, _, _) = setup();
    let dispatcher = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    let course_id = dispatcher.create_course(111111, 222222, 500, false, 333333);
    let course = dispatcher.get_course(course_id);

    assert(course.id == course_id, 'Course ID mismatch');
    assert(course.title == 111111, 'Course title mismatch');
    assert(course.description == 222222, 'Course description mismatch');
    assert(course.price == 500, 'Course price mismatch');
    assert(course.is_free == false, 'Course is_free flag mismatch');
    assert(course.tags == 333333, 'Course tags mismatch');
    assert(course.tutor == admin_address, 'Tutor address mismatch');
}

#[test]
fn test_enroll_course() {
    let (contract_address, admin_address, _, _, skillnet_wallet_address) = setup();
    let contract = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    let course_id = contract.create_course(23454, 54133, 100, false, 03485);
    let course = contract.get_course(course_id);
    let student: ContractAddress = contract_address_const::<'student'>();

    // Deposit funds to student to cover course price
    contract.deposit_funds(student, 1000_u256);

    let initial_tutor_balance = contract.get_balance(admin_address);
    let initial_skillnet_balance = contract.get_balance(skillnet_wallet_address);

    let result = contract.enroll_course(course_id, student);

    let final_tutor_balance = contract.get_balance(admin_address);
    let final_skillnet_balance = contract.get_balance(skillnet_wallet_address);
    let fee_amount = (course.price * 10_u256) / 10000_u256;

    assert!(result, "Enrollment failed");
    assert(
        final_skillnet_balance == initial_skillnet_balance + fee_amount,
        'SkillNet fee not received',
    );
    let tutor_cut = course.price - fee_amount;
    assert(final_tutor_balance == initial_tutor_balance + tutor_cut, 'Tutor fee not added');
}

#[test]
#[should_panic(expected: 'Course not found')]
fn test_should_fail_to_enroll_course_with_wrong_course_id() {
    let (contract_address, admin_address, _, _, _) = setup();
    let contract = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    let course_id = contract.create_course(23454, 54133, 100, false, 03485);
    let student: ContractAddress = contract_address_const::<'student'>();

    contract.enroll_course(course_id + 1, student);
}

#[test]
#[should_panic(expected: 'User already enrolled')]
fn test_should_fail_to_enroll_course_when_user_enrolled() {
    let (contract_address, admin_address, _, _, _) = setup();
    let contract = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    let course_id = contract.create_course(23454, 54133, 100, false, 03485);
    let student: ContractAddress = contract_address_const::<'student'>();

    // Deposit funds to student
    contract.deposit_funds(student, 1000_u256);

    contract.enroll_course(course_id, student);
    contract.enroll_course(course_id, student); // Should panic here
}

#[test]
#[should_panic(expected: 'Course not found')]
fn test_should_fail_to_pay_for_course_when_course_id_is_not_found() {
    let (contract_address, admin_address, _, _, _) = setup();
    let contract = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    let student: ContractAddress = contract_address_const::<'student'>();

    contract.process_course_payment(1, student, 1000);
}

#[test]
#[should_panic(expected: 'Course is free')]
fn test_should_fail_payment_when_course_is_free() {
    let (contract_address, admin_address, _, _, _) = setup();
    let contract = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    contract.deposit_funds(admin_address, 1000_u256);

    let course_id = contract.create_course(23454, 54133, 0, true, 03485);
    let course = contract.get_course(course_id);

    assert(course.is_free == true, 'Course not stored as free');

    let student: ContractAddress = contract_address_const::<'student'>();

    // Deposit funds to student to avoid overflow
    contract.deposit_funds(student, 10000_u256);

    contract.process_course_payment(course_id, student, 1000);
}

#[test]
#[should_panic(expected: 'Insufficient payment')]
fn test_should_fail_payment_when_price_greater_than_amount() {
    let (contract_address, admin_address, _, _, _) = setup();
    let contract = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    let course_id = contract.create_course(23454, 54133, 100000, false, 03485);
    let student: ContractAddress = contract_address_const::<'student'>();
    contract.process_course_payment(course_id, student, 100);
}

#[test]
fn test_upload_certificate_nft() {
    // Setup contract and addresses
    let (contract_address, admin_address, _, _, _) = setup();
    let contract = ISkillNetDispatcher { contract_address };

    // Create a course
    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    // Create a paid course
    let course_id = contract.create_course(123456, 654321, 100, false, 789012);

    // Setup student address
    let student: ContractAddress = contract_address_const::<'student'>();

    // Fund the student and enroll them in the course
    contract.deposit_funds(student, 1000_u256);
    contract.enroll_course(course_id, student);

    // Mark the course as completed by the student
    contract.complete_course(course_id, student);

    // Create certificate title
    let certificate_title: felt252 = 'Completion Certificate';

    // Upload certificate as NFT (admin is the tutor in this case)
    let token_id = contract.upload_certificate_nft(course_id, student, certificate_title);

    // Verify token ID is returned
    assert(token_id == 100, 'Incorrect token ID');

    // Verify ownership (in a real test, we'd check ownership via the NFT contract)
    let owner = contract.owner_of(token_id);
    assert(owner == admin_address, 'Incorrect token owner');
}

#[test]
#[should_panic(expected: 'Course not found')]
fn test_upload_certificate_nft_course_not_found() {
    // Setup contract and addresses
    let (contract_address, admin_address, _, _, _) = setup();
    let contract = ISkillNetDispatcher { contract_address };

    // Create a student address
    let student: ContractAddress = contract_address_const::<'student'>();

    // Try to upload certificate for non-existent course
    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);
    contract.upload_certificate_nft(999, student, 'Certificate');
}

#[test]
#[should_panic(expected: 'Not the course tutor')]
fn test_upload_certificate_nft_not_tutor() {
    // Setup contract and addresses
    let (contract_address, admin_address, _, _, _) = setup();
    let contract = ISkillNetDispatcher { contract_address };

    // Create a course
    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);
    let course_id = contract.create_course(123456, 654321, 100, false, 789012);

    // Setup student and another user addresses
    let student: ContractAddress = contract_address_const::<'student'>();
    let other_user: ContractAddress = contract_address_const::<'other_user'>();

    // Fund the student and enroll them in the course
    contract.deposit_funds(student, 1000_u256);
    contract.enroll_course(course_id, student);
    contract.complete_course(course_id, student);

    // Try to upload certificate as someone who isn't the tutor
    cheat_caller_address(contract_address, other_user, CheatSpan::Indefinite);
    contract.upload_certificate_nft(course_id, student, 'Certificate');
}

#[test]
#[should_panic(expected: 'Course not completed by student')]
fn test_upload_certificate_nft_course_not_completed() {
    // Setup contract and addresses
    let (contract_address, admin_address, _, _, _) = setup();
    let contract = ISkillNetDispatcher { contract_address };

    // Create a course
    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);
    let course_id = contract.create_course(123456, 654321, 100, false, 789012);

    // Setup student address
    let student: ContractAddress = contract_address_const::<'student'>();

    // Fund the student and enroll them in the course
    contract.deposit_funds(student, 1000_u256);
    contract.enroll_course(course_id, student);

    // Try to upload certificate without completing the course
    contract.upload_certificate_nft(course_id, student, 'Certificate');
}

