import "@stdlib/ownable";
import "./jetton";


message Mint {
    amount: Int;
    receiver: Address;
}

contract SampleJetton with Deployable, Jetton {
    totalSupply: Int as coins;
    owner: Address;
    mintable: Bool;
    content: Cell?;

    max_supply: Int as coins; // Extract parameter we set here. The Jetton Standards doesn't have this parameter.

    init(owner: Address, content: Cell, max_supply: Int) {
        self.totalSupply = 0;
        self.owner = owner;
        self.mintable = true;
        self.content = content;
        self.max_supply = max_supply;
    }

    receive(msg: Mint) {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner");
        require(self.mintable, "Not mintable");
        require(self.totalSupply + msg.amount <= self.max_supply, "Max supply exceeded");
        self.mint(msg.receiver, msg.amount, self.owner); // (to, amount, response_destination)
    }

    receive("Mint: 1000000000000000000") { // Public Minting
        let ctx: Context = context();
        
        require(self.mintable, "Not mintable");
        require(self.totalSupply + 1000000000000000000 <= self.max_supply, "Max supply exceeded");
    
        self.mint(ctx.sender, 1000000000000000000, self.owner); // 🔴 
    }

    receive("Owner: MintClose") {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner");
        self.mintable = false;
    }
} 