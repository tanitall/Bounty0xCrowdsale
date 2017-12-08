const CrowdsaleTokenController = artifacts.require('CrowdsaleTokenController');
const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');

contract('CrowdsaleTokenController', function (accounts) {
  let tc;
  let token;
  let crowdsale;
  let presale;

  before('get deployed bounty0x crowdsale contract', async () => {
    tc = await CrowdsaleTokenController.deployed();
    token = await Bounty0xToken.deployed();
    crowdsale = await Bounty0xCrowdsale.deployed();
    presale = await Bounty0xPresaleDistributor.deployed();
  });

  it('should be deployed', () => {
    assert.strictEqual(typeof crowdsale.address, 'string');
  });

  it('should know the address of the bounty0x token', async () => {
    const bounty0xToken = await tc.token();
    assert.strictEqual(bounty0xToken, token.address);
  });

  it('should have the crowdsale and presale whitelisted', async () => {
    const crowdsaleWhitelisted = await tc.isWhitelisted(crowdsale.address);
    assert.strictEqual(crowdsaleWhitelisted, true);

    const presaleWhitelisted = await tc.isWhitelisted(presale.address);
    assert.strictEqual(presaleWhitelisted, true);
  });

  it('only allows transfer from whitelisted addresses');
  it('only allows approval from whitelisted addresses');
});
