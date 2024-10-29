# PACCs PoC Implementation Specification

## Protocol Overview

Private, Anonymous, Collaterizable Commitments (PACCs) is a protocol to prevent maximal-extractable value (MEV) attacks in Decentralized Finance (DeFi). It is a commitment protocol based on smart contract wallets (SCWs) and Zero-Knowledge Proofs (ZKPs), that can be used to convince a relaying party that the user generating the PACC proof has enough funds to pay the required fees, that its wallet is committed to perform certain actions, and that the wallet loses some amount of collateral if this commitment is broken. Our PACCs proof-of-concept implementation, takes as an example the scenario where a user owning an External Owned Account (EOA) on Ethereum, is willing to perform a token exchange by means of the PACCs protocol, thus preventing any kind of MEV attack. We have three actors: the user willing to perform the exchange, a relaying party that forwards users' commitments to perform certain actions, the PACCs contract, and the DApp (in our PoC, a Decentralized Exchange (Dex)). The action can be performed by means of three transactions $(ptx_1, ptx_2, ptx_3)$. A simplified high-level overview of the protocol steps, for the sake of completeness, is as follows (and depicted in the following figure):

- **(user) top_up_token ($ptx_1$)**: send an amount of a given token to the PACCs contract, along with a $commitment Hash(r, S)$. Once the token is received, if the balance is greater than the collateral, the contract updates the user account with the new amount and adds the providedm commitment to the contract state. At this point, the commitment publicly belongs to ”someone” having enough funds to pay for the collateral. Plus, the tokens can only be spent if the opening to the commitment is revealed.

- **(user) send_zkp (off-chain)**: when a DApp action wants to be performed, the user first needs to commit to such action. As such, the user sends a PACCs ZKP to the relayer.

- **(relayer) commit_to_action ($ptx_2$)**: if the ZKP verifies, the relayer forwards the commitment $Hash(tx)$ and the value $S$ to the PACCs contract.
  
- **(PACCs contract) lock_collateral ($ptx_2$)**: upon receiving the commitment, the collateral gets locked in the contract. In particular, it places a restriction where the opening to the commitment $Hash(tx)$ needs to be revealed by who committed to $Hash(r, S)$ using $S$.
  
- **(user) order_action ($ptx_3$)**: after some time, the user orders the action, by issuing the promised transaction, thus revealing $tx$. Plus, the previous $r$ opening is revealed, and also a fresh new commitment $Hash(r, S)$ is provided.
  
- **(PACCs contract) unlock_collateral ($ptx_3$)**: if everything worked with no aborts, the collateral gets unlocked by removing the restriction.
  
- **(PACCs contract) execute_action ($ptx_3$)**: if the received order was indeed committed previously (i.e. the transaction itself is correct), the action is executed by calling the DApp. Plus, the commitment stored in the PACCs contract state gets replaced by the new one (or the existing one gets deleted if not enough funds remain to perform a new exchange).
