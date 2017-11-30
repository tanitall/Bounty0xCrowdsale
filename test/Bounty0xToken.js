const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');

contract('Bounty0xToken', ([ tokenController ]) => {
  let bounty0xtoken;
  let bounty0xCrowdsale;

  before('get the deployed bounty0x token', async () => {
    bounty0xtoken = await Bounty0xToken.deployed();
    bounty0xCrowdsale = await Bounty0xCrowdsale.deployed();
  });

  it('should be deployed', async () => {
    assert.strictEqual(typeof bounty0xtoken.address, 'string');
  });

  it('controller should be Bounty0xCrowdsale', async () => {
    const controller = await bounty0xtoken.controller();
    assert.strictEqual(controller, bounty0xCrowdsale.address);
  });
});