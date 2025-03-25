use starknet::ContractAddress;
use crate::types::CourseMetadata;

#[starknet::interface]
trait ISkillNetNFT<TContractState> {
    fn mint(
        ref self: TContractState, to: ContractAddress, course_id: u256, metadata: CourseMetadata,
    ) -> u256;

    fn transfer(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256,
    ) -> bool;

    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;

    fn get_metadata(self: @TContractState, token_id: u256) -> CourseMetadata;
}
