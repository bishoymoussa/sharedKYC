import { Client, Provider, ProviderRegistry, Result } from "@blockstack/clarity";
import { assert } from "chai";
describe("counter contract test suite", () => {
  let wrappedSTXClient: Client;
  let provider: Provider;
  before(async () => {
    provider = await ProviderRegistry.createProvider([
      {
        principal: 'SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB',
        amount: 1e6
      },
      {
        principal: 'ST11HGYVCVJ30Y8K7BEBHHZ52SFAV57095CEV4FQR',
        amount: 1e6
      },
    ]);
    wrappedSTXClient = new Client("SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB.wrapped-STX", "wrapped-STX", provider);
  });
  it("should have a valid syntax", async () => {
    await wrappedSTXClient.checkContract();
  });
  describe("deploying an instance of the contract", () => {
    before(async () => {
      await wrappedSTXClient.deployContract();
    });

    const getWSTXBalance = async () => {
      const query = await wrappedSTXClient.createQuery({
        method: {
          args: ["'SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB"],
          name: "get-balance-of"
        }
      })
      const receipt = await wrappedSTXClient.submitQuery(query);
      return Result.unwrapUInt(receipt)
    }
    
    it("should start at zero", async () => {
      const query = await wrappedSTXClient.createQuery({
        method: {
          args: [],
          name: "get-total-supply"
        }
      })
      const receipt = await wrappedSTXClient.submitQuery(query);
      const result = Result.unwrapUInt(receipt)
      assert.equal(result, 0);
    })


    it("should wrap stx", async () => {
      const initialBalance = await getWSTXBalance();
      
      assert.equal(initialBalance, 0);

      const tx = wrappedSTXClient.createTransaction({
        method: {
          name: 'wrap',
          args: ['u100']
        }
      })

      tx.sign("SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB")
      await wrappedSTXClient.submitTransaction(tx);

      const balance = await getWSTXBalance();

      
      assert.equal(balance, 100);
    })

    it("should unwrap stx", async () => {
      const initialBalance = await getWSTXBalance();
      
      assert.equal(initialBalance, 100);

      const tx = wrappedSTXClient.createTransaction({
        method: {
          name: 'unwrap',
          args: ['u100']
        }
      })

      tx.sign("SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB")
      await wrappedSTXClient.submitTransaction(tx);

      const balance = await getWSTXBalance();

      
      assert.equal(balance, 0);
    })
    it("should show us its full name", async () => {
      const query = wrappedSTXClient.createQuery({
        method: {
          name: 'get-name',
          args: []
        }
      })

      const receipt = await wrappedSTXClient.submitQuery(query);
      assert.equal(Result.unwrap(receipt), '(ok "Wrapped-STX")')
    })
    it("should show us its symbol", async () => {
      const query = wrappedSTXClient.createQuery({
        method: {
          name: 'get-symbol',
          args: []
        }
      })

      const receipt = await wrappedSTXClient.submitQuery(query);
      assert.equal(Result.unwrap(receipt), '(ok "WSTX")')
    })
    // it("should decrement", async () => {
    //   await execMethod("decrement");
    //   assert.equal(await getCounter(), 1);
    //   await execMethod("decrement");
    //   assert.equal(await getCounter(), 0);
    // })
  });
  after(async () => {
    await provider.close();
  });
});
