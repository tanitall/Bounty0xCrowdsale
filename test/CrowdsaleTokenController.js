import { ZERO_ADDRESS } from './helpers/util';
import expectThrow from './helpers/expectThrow';

const CrowdsaleTokenController = artifacts.require('CrowdsaleTokenController');
const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');

contract('CrowdsaleTokenController', function (accounts) {
  let deployedTokenController;
  let deployedToken;
  let deployedCrowdsale;
  let deployedPresale;

  before('get deployed bounty0x crowdsale contract', async () => {
    deployedTokenController = await CrowdsaleTokenController.deployed();
    deployedToken = await Bounty0xToken.deployed();
    deployedCrowdsale = await Bounty0xCrowdsale.deployed();
    deployedPresale = await Bounty0xPresaleDistributor.deployed();
  });

  it('should be deployed', () => {
    assert.strictEqual(typeof deployedCrowdsale.address, 'string');
  });

  it('should know the address of the bounty0x token', async () => {
    const bounty0xToken = await deployedTokenController.token();
    assert.strictEqual(bounty0xToken, deployedToken.address);
  });

  it('should have the crowdsale and presale whitelisted', async () => {
    assert.strictEqual(await deployedTokenController.isWhitelisted(deployedCrowdsale.address), true);
    assert.strictEqual(await deployedTokenController.isWhitelisted(deployedPresale.address), true);
  });

  it('only allows transfer from whitelisted addresses', async () => {
    for (let acct of [ deployedCrowdsale.address, deployedPresale.address ]) {
      assert.strictEqual(await deployedTokenController.onTransfer.call(acct, ZERO_ADDRESS, 0), true);
    }

    for (let acct of [ deployedToken.address ].concat(accounts)) {
      assert.strictEqual(await deployedTokenController.onTransfer.call(acct, ZERO_ADDRESS, 0), false);
    }
  });

  it('only allows approval from whitelisted addresses', async () => {
    for (let acct of [ deployedCrowdsale.address, deployedPresale.address ]) {
      assert.strictEqual(await deployedTokenController.onApprove.call(acct, ZERO_ADDRESS, 0), true);
    }

    for (let acct of [ deployedToken.address ].concat(accounts)) {
      assert.strictEqual(await deployedTokenController.onApprove.call(acct, ZERO_ADDRESS, 0), false);
    }
  });

  it('allows the owner to change the token controller', async () => {
    const [ owner, ...others ] = accounts;

    // create the contracts
    const newToken = await Bounty0xToken.new(ZERO_ADDRESS, { from: owner });
    const newTokenController = await CrowdsaleTokenController.new(newToken.address, { from: owner });

    // point newToken at newTokenController
    await newToken.changeController(newTokenController.address, { from: owner });

    // iterate through the accounts asserting that you cannot
    for (let acct of others) {
      await expectThrow(newTokenController.changeController(ZERO_ADDRESS, { from: acct }));
    }

    // give token to address 0
    await newTokenController.changeController(ZERO_ADDRESS, { from: owner });
  });

  it('does not accept any payment to the token contract', async () => {
    for (let acct of accounts.concat([ deployedToken.address, deployedCrowdsale.address, deployedPresale.address ])) {
      assert.strictEqual(await deployedTokenController.proxyPayment.call(acct), false);
    }
  });
});
