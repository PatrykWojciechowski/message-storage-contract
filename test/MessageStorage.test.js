const MessageStorage = artifacts.require("MessageStorage");
const chai = require("chai");
const expect = chai.expect;
const truffleAssert = require('truffle-assertions');

contract("MessageStorage Test", async (accounts) => {

    let instance;

    beforeEach(async () => {
        instance  = await MessageStorage.deployed();
    });

    it("should be created", async () => {
        expect(instance).to.be.exist;
    });

    it("should set the owner on creation", async () => {
        const owner = await instance.owner();
        expect(owner).to.exist;
        expect(owner).to.equal(accounts[0]);
    });

    it("should be able to add data", async () => {
        await instance.addData("Hello World", "Patryk", {from: accounts[0]});

        const result = await instance.messages.call(accounts[0]);
        expect(result[1]).to.equal("Hello World");
        expect(result[0]).to.equal("Patryk");
    });

    it("should be able to remove data", async () => {
        await instance.addData("Hello World", "Patryk");
        await instance.removeDataFromOwnAddress();

        const result = await instance.messages.call(accounts[0]);
        expect(result[0]).to.equal("");
        expect(result[1]).to.equal("");
    });

    it("owner should be able to remove someone's message", async () => {
        await instance.addData("Hello World", "Patryk", {from: accounts[1]});
        await instance.removeDataFromAnyAddress(accounts[1]);

        const result = await instance.messages.call(accounts[1]);
        expect(result[0]).to.equal("");
        expect(result[1]).to.equal("");
    });

    it("normal user should not be able to remove someone's message", async () => {
        await instance.addData("Hello World", "Patryk", {from: accounts[0]});
        await truffleAssert.reverts(
            instance.removeDataFromAnyAddress(accounts[0], {from: accounts[1]}),
            "Only owner is allowed to do this!"
        );
    });

    it("normal user should not be able to destruct contract", async () => {
        await truffleAssert.reverts(
            instance.terminate({from: accounts[1]}),
            "Only owner is allowed to do this!"
        );
    });

});


