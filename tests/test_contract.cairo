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
fn test_create_course() {
    let (contract_address, admin_address, _, _, _) = setup();
    let dispatcher = ISkillNetDispatcher { contract_address };

    // Test input values
    let title: felt252 = 123456; // Example felt252 value
    let description: felt252 = 654321; // Example felt252 value
    let price: u256 = 1000;
    let is_free: bool = false;
    let tags: felt252 = 789012; // Example felt252 value

    // Ensure the caller is the admin
    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

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
    let (contract_address, admin_address, _, _, _) = setup();
    let contract = ISkillNetDispatcher { contract_address };

    cheat_caller_address(contract_address, admin_address, CheatSpan::Indefinite);

    let course_id = contract.create_course(23454, 54133, 100, false, 03485);
    let student: ContractAddress = contract_address_const::<'student'>();

    let result = contract.enroll_course(course_id, student);
    assert!(result, "Enrollment failed");
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

    contract.enroll_course(course_id, student);
    contract.enroll_course(course_id, student);
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

    let course_id = contract.create_course(23454, 54133, 0, true, 03485);
    let student: ContractAddress = contract_address_const::<'student'>();
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

