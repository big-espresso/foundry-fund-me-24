#Data types

Boolean:

    Represents true or false values.
    Example: bool isTrue = true;

Integer Types:

    Various sizes, both signed and unsigned.
    Examples:

    solidity

    uint256 unsignedInteger = 42;
    int256 signedInteger = -42;

Address:

    Represents a 20-byte Ethereum address.
    Example: address userAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

String:

    Represents a variable-length string of UTF-8 characters.
    Example: string greeting = "Hello, World!";

Bytes:

    Dynamically-sized byte array.
    Example: bytes memory data = new bytes(10);

Fixed and Floating-Point Numbers:

    Fixed-point numbers (fixed) have a fixed number of decimal places.
    Floating-point numbers (float) adhere to the IEEE 754 standard.
    Examples:

    solidity

    fixed f = 3.14;
    float g = 3.14e10;

Enums:

    User-defined types with a set of named values.
    Example:

    solidity

    enum State { Pending, Approved, Rejected }
    State currentState = State.Pending;

Mapping:

    Key-value pairs where the keys and values can be of any type.
    Example: mapping(address => uint256) balances;

Array:

    Collection of elements of the same type.
    Can be dynamic or fixed-size.
    Examples:

    solidity

        uint256[] dynamicArray;
        uint256[5] fixedArray;

These are the fundamental types in Solidity, and they provide the building blocks for defining variables with different data structures and characteristics in smart contracts. Understanding these types is crucial for developing robust and efficient Solidity code.

#Variable types

Memory:

    memory is a temporary place where data is stored during the execution of a function.
    It is used for storing variables that are only needed during the execution of a function and are not required to be persisted between function calls.
    Memory is cleared between (external) function calls and is more expensive to use in terms of gas compared to storage.

Example:

solidity
```
function add(uint256 a, uint256 b) public pure returns (uint256) {
    uint256 result;
    result = a + b;  // 'result' is stored in memory
    return result;
}
```

Calldata:

    calldata is a special, read-only area where function arguments are stored.
    It is used to store the function parameters passed from external callers to the contract.
    Functions can only read from calldata; they cannot modify its contents.
    Access to calldata is cheaper in terms of gas compared to storage.

Example:

solidity
```
function getDataFromCalldata(uint256[] calldata values) public pure returns (uint256) {
    uint256 sum;
    for (uint256 i = 0; i < values.length; i++) {
        sum += values[i];
    }
    return sum;
}
```

Storage:

    storage is a persistent storage area where contract state variables are stored.
    State variables in storage persist between function calls and transactions, making them suitable for storing data that needs to be permanently stored on the blockchain.
    Accessing or modifying data in storage is more gas-expensive compared to memory or calldata.

Example:

solidity
```
    contract StorageExample {
        uint256 public myVariable;  // 'myVariable' is stored in storage

        function setMyVariable(uint256 newValue) public {
            myVariable = newValue;
        }

        function getMyVariable() public view returns (uint256) {
            return myVariable;
        }
    }
```

In summary, memory is temporary storage, calldata is read-only storage for function arguments, and storage is persistent storage for contract state variables. Understanding when to use each is crucial for optimizing gas usage and ensuring the correct behavior of your smart contracts.


#Function types

view Functions:

    Functions declared as view do not modify the state of the contract.
    They are read-only and do not consume any gas when called externally.
    view functions can read the state variables of the contract but cannot modify them.
    They are often used to retrieve information from the contract without changing its state.

Example:

solidity
```
contract MyContract {
    uint256 public myVariable;

    function getValue() public view returns (uint256) {
        return myVariable;
    }
}
```

pure Functions:

    Functions declared as pure are even more restrictive than view functions.
    They do not read or modify the state of the contract.
    They do not access any state variables or call any other functions that are not also declared as pure.
    pure functions are useful for mathematical calculations or utility functions that don't rely on contract state.

Example:

solidity
```
    contract MathOperations {
        function add(uint256 a, uint256 b) public pure returns (uint256) {
            return a + b;
        }
    }
```
In summary, the key difference is that view functions can read the state but not modify it, while pure functions cannot read or modify the state at all. Both are used to indicate to the compiler and other developers the intended behavior of the function and provide optimizations and security guarantees.


#Function visibility and mutability

In Solidity, functions can have different visibility and state mutability modifiers. Here's a summary of the function types:

    External:
        Can be called from other contracts or transactions.
        Cannot be called internally (from within the same contract).
        Example: function externalFunction() external { ... }

    Public:
        Can be called from other contracts, transactions, or internally.
        Generates a getter function for public state variables.
        Example:

        solidity

    uint256 public myVariable;

    function setMyVariable(uint256 newValue) public {
        myVariable = newValue;
    }

Internal:

    Can only be called internally (from within the same contract or derived contracts).
    Not accessible from external contracts or transactions.
    Example: function internalFunction() internal { ... }

Private:

    Can only be called from within the same contract.
    Not accessible from derived contracts or external contracts.
    Example: function privateFunction() private { ... }

View:

    Does not modify the state of the contract.
    Can be called both internally and externally.
    Example: function viewFunction() public view returns (uint256) { ... }

Pure:

    Does not read or modify the state of the contract.
    Can be called both internally and externally.
    Example: function pureFunction() public pure returns (uint256) { ... }

Payable:

    Allows the function to receive Ether.
    Can be combined with other visibility modifiers.
    Example: function receiveEther() public payable { ... }

Fallback:

    Executed when a contract receives Ether but the transaction does not match any function signature.
    Implicitly defined without a name.
    Example:

    solidity

        receive() external payable {
            // Fallback logic
        }

These modifiers help control the access and behavior of functions within Solidity contracts. The combination of visibility and state mutability modifiers provides a flexible way to design and secure smart contract functions based on specific requirements.

#Inheritance

Contracts can interact between each other seamlessly this feature is called COMPOSEABILITY (similar to importing a library in python)



===========================================

<!-- start anvil -->
<!-- anvil creates a local testnet -->
anvil

forge init

<!-- Deploy contract to a chain by hand -->
forge create SimpleStorage --rpc-url http://127.0.0.1:8545 --interactive

<!-- delete history in bash -->
history -c

<!-- run script -->
<!-- when running scripts without a blockchain the script output goes to a dir called dry-run -->
forge script script/DeploySimpleStorage.s.sol (simulation)

forge script script/DeploySimpleStorage.s.sol --rpc-url http://127.0.0.1:8545 --private-key [only for testing, use .env] --broadcast (deploy)

<!-- easy numeric conversions with cast -->
cast --to-base 0x714c2 dec


<!-- send a transaction -->
cast send [address] "store(uint256)" 123 --rpc-url $RPC_URL --private-key $PRIVATE_KEY

<!-- read from the blockchain -->
cast call [address] "retrieve()"

<!-- auto format code -->
forge fmt

<!-- trouble with remmappings -->
forge remappings > remappings.txt

<!-- install dependencies.
    this is needed because foundry doesn't use npm -->

forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit

forge test -vv

forge test -m [NAME OF THE TEST FUNCTION] --fork-url $RPC_URL


<!-- check test coverage -->
forge coverage





<!-- CREATING A MOCK CONTRACT
     -->


<!-- allows testing solidity directly in the terminal -->
chisel


<!-- tell the gas price of a test -->
forge snapshot --match-test


<!-- STORAGE -->

vars inside functions only exist in momory and are temporary
vars in the contract level occupy sorage slots
if the var is immutable or constant it is instead save in the ontract bytecode



<!-- Inspect storage structure of the contract -->
forge inspect [FundMe] storageLayout


<!-- This will show the storage of any contract -->
cast storage [contract address]


<!-- keeps track of opcodes gas price -->
evm.codes


<!-- MAKEFILE -->





