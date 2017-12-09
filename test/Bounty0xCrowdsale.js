import { withinPercentage, ZERO_ADDRESS } from './helpers/util';
import { MAINSALE_POOL } from '../migrations/constants';
import expectThrow from './helpers/expectThrow';

const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');
const MockBounty0xCrowdsale = artifacts.require('MockBounty0xCrowdsale');

contract('Bounty0xCrowdsale', function ([ deployer, presaleContributor1, presaleContributor2, contributor1, contributor2 ]) {
  let deployedCrowdsale, deployedToken;

  before('get deployed bounty0x crowdsale contract', async () => {
    deployedCrowdsale = await Bounty0xCrowdsale.deployed();
    deployedToken = await Bounty0xToken.deployed();
  });

  it('should be deployed', () => {
    assert.strictEqual(typeof deployedCrowdsale.address, 'string');
  });

  it('should have crowdsale balance', async () => {
    const knowsToken = await deployedCrowdsale.bounty0xToken();
    assert.strictEqual(knowsToken, deployedToken.address);

    const balance = await deployedToken.balanceOf(deployedCrowdsale.address);
    assert.strictEqual(balance.valueOf(), '9.09e+25');
  });

  describe('MockBounty0xCrowdsale', () => {
    let token, crowdsale, saleStartDate, saleEndDate, whitelistEndDate, limitsEndDate, maxGasPrice, maxGas,
      minContributionWei, hardCapWei, maxContributionWeiWhitelist, maxContributionWeiPostWhitelist;

    // if 1 ether === 15 million USD, we can saturate the crowdsale with .1 ETH
    const USD_ETHER_PRICE = 15 * Math.pow(10, 6);

    beforeEach('deploy a fresh crowdsale', async () => {
      token = await Bounty0xToken.new(ZERO_ADDRESS, { from: deployer });

      crowdsale = await MockBounty0xCrowdsale.new(token.address, USD_ETHER_PRICE, { from: deployer });

      await token.generateTokens(crowdsale.address, MAINSALE_POOL * Math.pow(10, 18), { from: deployer });

      // whitelist the presale contributors
      await crowdsale.addToWhitelist([ presaleContributor1, presaleContributor2 ], { from: deployer });

      saleStartDate = await crowdsale.SALE_START_DATE();
      saleEndDate = await crowdsale.SALE_END_DATE();
      whitelistEndDate = await crowdsale.WHITELIST_END_DATE();
      limitsEndDate = await crowdsale.LIMITS_END_DATE();
      maxGasPrice = await crowdsale.MAX_GAS_PRICE();
      maxGas = await crowdsale.MAX_GAS();

      const minParticipationUsd = await crowdsale.MINIMUM_PARTICIPATION_AMOUNT_USD();
      const hardCapUsd = await crowdsale.HARD_CAP_AMOUNT_USD();
      const maxContributionUsdWhitelist = await crowdsale.MAXIMUM_CONTRIBUTION_AMOUNT_USD_DURING_WHITELIST();
      const maxContributionUsdPostWhitelist = await crowdsale.MAXIMUM_CONTRIBUTION_AMOUNT_USD_POST_WHITELIST();

      minContributionWei = await crowdsale.usdToWei(minParticipationUsd);
      hardCapWei = await crowdsale.usdToWei(hardCapUsd);
      maxContributionWeiWhitelist = await crowdsale.usdToWei(maxContributionUsdWhitelist);
      maxContributionWeiPostWhitelist = await crowdsale.usdToWei(maxContributionUsdPostWhitelist);
    });

    async function contribute(from, amount, gas = maxGas, gasPrice = maxGasPrice) {
      // crowdsale time
      const time = await crowdsale.currentTime();

      // this limits our contributions to these values
      const tx = await crowdsale.sendTransaction({ from, value: amount, gasPrice, gas });

      const { receipt: { gasUsed }, logs } = tx;

      assert.strictEqual(logs.length, 1);
      assert.strictEqual(logs[ 0 ].event, 'OnContribution');
      assert.strictEqual(logs[ 0 ].args.contributor, from);
      assert.strictEqual(logs[ 0 ].args.duringWhitelistPeriod, time < whitelistEndDate);
      assert.strictEqual(logs[ 0 ].args.contributedWei.sub(amount).valueOf(), '0');
      withinPercentage(logs[ 0 ].args.bntyAwarded, (USD_ETHER_PRICE * amount) / 0.0165);
      assert.strictEqual(gasUsed < maxGas, true);

      return tx;
    }

    it('allows the owner to withdraw ether at any time', async () => {
      // first make a contribution
      await crowdsale.setTime(limitsEndDate);

      // contribute 1 gwei
      await contribute(contributor1, minContributionWei);

      // no one can withdraw
      for (let acct of [ presaleContributor1, presaleContributor2, contributor1, contributor2 ]) {
        await expectThrow(crowdsale.withdraw(1, { from: acct }));
      }

      const { logs: [ { args: { to, amount } } ] } = await crowdsale.withdraw(1, { from: deployer });
      assert.strictEqual(to, deployer);
      assert.strictEqual(amount.valueOf(), '1');
    });

    it('does not accept contributions while paused', async () => {
      await crowdsale.setTime(whitelistEndDate - 1);

      await contribute(presaleContributor1, minContributionWei);

      await crowdsale.pause({ from: deployer });

      await expectThrow(contribute(presaleContributor1, minContributionWei));

      await crowdsale.unpause({ from: deployer });

      await contribute(presaleContributor1, minContributionWei);
    });

    it('does not accept 0 value contributions', async () => {
      await crowdsale.setTime(limitsEndDate + 1);
      await expectThrow(contribute(presaleContributor1, 0));
    });

    it('should not accept contributions until SALE_START_DATE', async () => {
      await crowdsale.setTime(saleStartDate - 1);
      await expectThrow(contribute(presaleContributor1, minContributionWei));

      await crowdsale.setTime(saleStartDate);
      await contribute(presaleContributor1, minContributionWei);
    });

    it('should not accept contributions after SALE_END_DATE', async () => {
      await crowdsale.setTime(saleEndDate - 1);
      await contribute(contributor1, minContributionWei);

      await crowdsale.setTime(saleEndDate);
      await expectThrow(contribute(contributor1, minContributionWei));
    });

    it('should not accept contributions beyond hard cap', async () => {
      await crowdsale.setTime(limitsEndDate);

      // todo: finish test
      await contribute(contributor1, hardCapWei / 2);
    });

    it('only accepts contributions greater than the minimum amount');
    it('only accepts contributions from whitelisted addresses in first 24 hours');
    it('only accepts $1.5k USD per address during whitelist period');
    it('accepts contributions from any address after the whitelist period for 24 hours');
    it('limits gas price sent with contributions for 24 hours after whitelist period');
    it('limits gas sent with contributions for 24 hours after whitelist period');
    it('limits total contributions to $10k USD for 24 hours after whitelist period');
    it('adds to total contributions for each wei sent');
    it('records contributions by address correctly');
    it('rewards the correct amount of BNTY for contributions');

  });
});
