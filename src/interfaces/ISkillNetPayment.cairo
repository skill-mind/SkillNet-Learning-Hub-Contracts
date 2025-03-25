use starknet::ContractAddress;


#[starknet::interface]
trait ISkillNetPayment<TContractState> {
    fn process_payment(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, amount: u256,
    ) -> bool;

    fn withdraw_funds(ref self: TContractState, account: ContractAddress, amount: u256) -> bool;

    fn get_balance(self: @TContractState, account: ContractAddress) -> u256;
}
