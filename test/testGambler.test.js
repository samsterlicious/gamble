const Gambler = artifacts.require("Gambler");
const { v4: uuidv4 } = require("uuid");
const web3 = require("web3");

contract("Gambler", (accounts) => {
  before(async () => {
    console.log("deployed");
    gambler = await Gambler.deployed();
  });

  describe("creating account and betting", async () => {
    it("betting on first choice", async () => {
      const key = web3.utils.asciiToHex(uuidv4()).substring(0, 66);

      const now = new Date();
      const cutoffDate = Math.floor(now.getTime() / 1000);
      now.setDate(now.getDate() + 5);
      const settleDate = Math.floor(now.getTime() / 1000);

      const firstChoice = "first";
      const secondChoice = "second";

      await gambler.createBet(
        firstChoice,
        secondChoice,
        true,
        key,
        cutoffDate,
        settleDate,
        {
          from: accounts[0],
          value: 50000,
        }
      );

      const bet = await gambler.bets(key);

      assert.equal(
        bet.fighterOne,
        firstChoice,
        "The bet's first choice is incorrect"
      );

      assert.equal(
        bet.fighterTwo,
        secondChoice,
        "The bet's second choice is incorrect"
      );

      assert.equal(bet.pickedFirst, true, "The owner's choice is incorrect");

      assert.equal(bet.amount, 50000, "Bet amount should equal 50000");
    });
  });
});
