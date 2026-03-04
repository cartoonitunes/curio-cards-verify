# Curio Cards - Verified Source Code

Recovered and verified source code for the **Curio Cards v2 factory contracts** deployed June 20, 2017.

## Contract

| Field | Value |
|-------|-------|
| **Address** | [`0x8ccf904e75bc592df3db236cd171d0caf0b2bbcb`](https://etherscan.io/address/0x8ccf904e75bc592df3db236cd171d0caf0b2bbcb) |
| **Name** | Curio18 (CRO18) |
| **Total Supply** | 500 |
| **Compiler** | solc 0.4.8+commit.60cc1668 |
| **Optimizer** | Off |
| **Block** | [3,902,090](https://etherscan.io/block/3902090) |
| **Factory** | [`0xeca65be784e2b0f1956d266c1237481a511a19fb`](https://etherscan.io/address/0xeca65be784e2b0f1956d266c1237481a511a19fb) |
| **Creation Tx** | [`0xd4b7233e...`](https://etherscan.io/tx/0xd4b7233ed1429da5a61d35e74500aca145abe4e18dfc015b0481aeaf4ae0e588) |

## What's Different

The well-known Curio Cards source ([`17b-erc20.sol`](https://github.com/curiocards/wrapper-contracts/blob/master/contracts/17b-erc20.sol)) matches **Cards 1-17** (verified via [Card 1 on Etherscan](https://etherscan.io/address/0x6Aa2044C7A0f9e2758EdAE97247B03a0D7e73d6c#code)).

Cards 17-19 were deployed by a **different factory** (`0xeca65Be7...`) using an updated contract with one additional field:

```solidity
string public thumbnail;  // slot 5 - second IPFS hash for thumbnail image
```

This shifts `description` from slot 5 to slot 6 and adds the `thumbnail()` getter (selector `0x5afc2ab4`).

The factory's `CreateCard()` function takes 6 parameters instead of 5:

```solidity
function CreateCard(
    uint256 _initialAmount,
    string _name,
    string _symbol,
    string _desc,
    string _ipfshash,
    string _thumbnail    // new parameter
) returns (address)
```

## Sibling Contracts

All three were created by the same factory in the same session:

| Card | Address | Block |
|------|---------|-------|
| Curio17 | [`0xe0b5e6f32d657e0e18d4b3e801ebc76a5959e123`](https://etherscan.io/address/0xe0b5e6f32d657e0e18d4b3e801ebc76a5959e123) | 3,902,088 |
| Curio18 | [`0x8ccf904e75bc592df3db236cd171d0caf0b2bbcb`](https://etherscan.io/address/0x8ccf904e75bc592df3db236cd171d0caf0b2bbcb) | 3,902,090 |
| Curio19 | [`0x6b3485c6eb9027f4f02e495f42708b5896e2579b`](https://etherscan.io/address/0x6b3485c6eb9027f4f02e495f42708b5896e2579b) | 3,902,106 |

These are **separate deployments** from the "official" Curio Cards listed on [vintage.curio.cards](https://vintage.curio.cards), which use a different factory (`0x37aab220...`). The official Card 18 is at [`0xA507D9d28bbca54cBCfFad4BB770C2EA0519F4F0`](https://etherscan.io/address/0xA507D9d28bbca54cBCfFad4BB770C2EA0519F4F0).

## Storage Layout

| Slot | Type | Field |
|------|------|-------|
| 0 | `address` | `owner` |
| 1 | `string` | `standard` ("Token 0.1") |
| 2 | `string` | `name` |
| 3 | `string` | `symbol` |
| 4 | `string` | `ipfs_hash` |
| 5 | `string` | `thumbnail` |
| 6 | `string` | `description` |
| 7 | `bool` + `uint8` | `isLocked` + `decimals` (packed) |
| 8 | `uint256` | `totalSupply` |
| 9 | `mapping` | `balanceOf` |
| 10 | `mapping` | `allowance` |

## IPFS Content

| Field | Hash |
|-------|------|
| `ipfs_hash` | `QmajPpYuqQVasd9AzTYUaDrPW6nzjigY91evEUDoNiuefW` |
| `thumbnail` | `QmXcwMsBfmpKLHQueXeBpju9GgPKTerzj6BHbAu7g6PMmR` |

## Verification

```bash
./verify.sh
```

Downloads solc 0.4.8, compiles `CurioCard.sol` without optimizer, and compares the runtime bytecode against on-chain (excluding Swarm metadata hash).

```
Compiled:  5876 bytes
On-chain:  5876 bytes
✅ EXACT MATCH (excluding Swarm hash)
```

## How We Found It

1. Fetched on-chain bytecode and decoded 20 function selectors from the dispatch table
2. Matched 19/20 to the known `17b-erc20.sol` source from the [curiocards/wrapper-contracts](https://github.com/curiocards/wrapper-contracts) repo
3. One unknown selector `0x5afc2ab4` remained - not in 4byte.directory
4. Storage analysis revealed an extra string field at slot 5 containing a second IPFS hash
5. [OpenChain signature database](https://api.openchain.xyz) identified `0x5afc2ab4` as `thumbnail()`
6. Added `string public thumbnail` to the source, compiled with solc 0.4.8 (no optimizer) - exact bytecode match

## License

Source code recovery and verification only. Original contract by the [Curio Cards](https://curio.cards) team (2017).
