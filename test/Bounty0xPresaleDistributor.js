import { withinPercentage, ZERO_ADDRESS } from './helpers/util';

const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const MockBounty0xPresale = artifacts.require('MockBounty0xPresale');

contract('Bounty0xPresaleDistributor', function ([ deployer, contributor1, contributor2, nonContributor1, nonContributor2 ]) {
  let bounty0xPresaleDstributor;

  before('get deployed bounty0x crowdsale contract', async () => {
    bounty0xPresaleDstributor = await Bounty0xPresaleDistributor.deployed();
  });

  it('should be deployed', () => {
    assert.strictEqual(typeof bounty0xPresaleDstributor.address, 'string');
  });

  describe('#compensatePreSaleInvestors', async () => {
    let presaleContract, distributor, token;

    beforeEach('set up the contract with contributors', async () => {
      token = await Bounty0xToken.new(ZERO_ADDRESS, { from: deployer });
      await token.enableTransfers(true);

      presaleContract = await MockBounty0xPresale.new(
        [ contributor1, contributor2 ],
        [ Math.pow(10, 18), 3 * Math.pow(10, 18) ],
        { from: deployer }
      );

      distributor = await Bounty0xPresaleDistributor.new(token.address, presaleContract.address);

      // give it 1 million tokens (smaller for testing)
      await token.generateTokens(distributor.address, Math.pow(10, 24), { from: deployer });
    });

    it('can be called by anyone', async () => {
      for (let acct of [ deployer, contributor1, contributor2, nonContributor1, nonContributor2 ]) {
        const { logs } = await distributor.compensatePreSaleInvestors([], { from: acct });
        assert.strictEqual(logs.length, 0);
      }
    });

    it('does nothing if they did not contribute', async () => {
      const { logs } = await distributor.compensatePreSaleInvestors([ nonContributor1 ], { from: deployer });
      assert.strictEqual(logs.length, 0);
    });

    it('pays out if they did contribute', async () => {
      // log: OnPreSaleBuyerCompensated
      const { logs } = await distributor.compensatePreSaleInvestors([ contributor1 ], { from: deployer });
      assert.strictEqual(logs.length, 1);
      assert.strictEqual(logs[ 0 ].event, 'OnPreSaleBuyerCompensated');
      assert.strictEqual(logs[ 0 ].args.contributor, contributor1);

      // contributor1 sent 1 eth and should get eth price/usd per bnty bntys (each with 18 decimals)
      const EXPECTED_PAYOUT = (355 / 0.0132) * Math.pow(10, 18);

      // check the log is correct
      withinPercentage(logs[ 0 ].args.numTokens, EXPECTED_PAYOUT);

      // make sure they were actually paid
      const tokenBalance = await token.balanceOf(contributor1);
      withinPercentage(tokenBalance, EXPECTED_PAYOUT);

      // does not pay out any investor twice
      const { logs: secondTime } = await distributor.compensatePreSaleInvestors([ contributor1 ], { from: deployer });
      assert.strictEqual(secondTime.length, 0);
    });
  });

});
