const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');

contract('Bounty0xCrowdsale', function (accounts) {
  let bounty0xPresaleDstributor;

  before('get deployed bounty0x crowdsale contract', async () => {
    bounty0xPresaleDstributor = await Bounty0xCrowdsale.deployed();
  });

  it('should be deployed', () => {
    assert.strictEqual(typeof bounty0xPresaleDstributor.address, 'string');
  });

});
