import { expect } from 'chai'
import {ethers} from 'hardhat'

import * as dotenv from 'dotenv'


dotenv.config()

describe('Citizen', function () {
    before(async function () {
        this.signers = await ethers.getSigners()
        this.owner = this.signers[0]
    })

    beforeEach(async function () {
        const Battle = await ethers.getContractFactory("BattleShips");
        const battle = await Battle.deploy()
        await battle.deployed()

        this.battle = battle

        


    })

    it('Should BE DEPLOYED', async function () {
        expect(this.battle).not.to.be.empty
       
    })

    it('Should BE create room', async function () {
              
        await expect(await this.battle.createRoom()).to.be.emit(this.battle, "RoomCreated").withArgs(0)
        await expect(await this.battle.createRoom()).to.be.emit(this.battle, "RoomCreated").withArgs(1)
    })

    it('Should BE join to room', async function () {
              
       await this.battle.createRoom()
        await expect(await this.battle.connect(this.signers[1]).joinRoom(0)).to.be.emit(this.battle, "MatchWasStarted").withArgs(0, 1)
    })
    
    it.only('Should BE DOMOVE to room', async function () {
              
        await this.battle.createRoom()
        await this.battle.connect(this.signers[1]).joinRoom(0)

        let signatures1 = [
            await this.owner.signMessage("00F"),
            await this.owner.signMessage("10T"),
            await this.owner.signMessage("20F")
        ]

        let signatures2 = [
            await this.signers[1].signMessage("00F"),
            await this.signers[1].signMessage("10T"),
            await this.signers[1].signMessage("20F")
        ]
        await this.battle.doMove(0, signatures1)
        await this.battle.connect(this.signers[1]).doMove(0, signatures2)
        
        console.log(this.signers[0].address)
        console.log(signatures1[0]);
        

        
        // await this.battle.connect(this.signers[2]).confirmMove(0, ['00T', '10F','20F'])
        await this.battle.connect(this.signers[1]).confirmMove(0, ['00F', '10T','20F'])
        await this.battle.confirmMove(0, ['00F', '10T','20F'])
        console.log(await this.battle.getDestroyedParts(0));

        let signatures3 = [
            await this.owner.signMessage("00T"),
            await this.owner.signMessage("10F"),
            await this.owner.signMessage("20F")
        ]

        let signatures4 = [
            await this.signers[1].signMessage("00F"),
            await this.signers[1].signMessage("10T"),
            await this.signers[1].signMessage("20F")
        ]

        await this.battle.doMove(0, signatures3)
        await this.battle.connect(this.signers[1]).doMove(0, signatures4)
        
        await this.battle.connect(this.signers[1]).confirmMove(0, ['00F', '10T','20F'])
        await this.battle.confirmMove(0, ['00T', '10F','20F'])

        console.log(await this.battle.getDestroyedParts(0));
     })
    


})
