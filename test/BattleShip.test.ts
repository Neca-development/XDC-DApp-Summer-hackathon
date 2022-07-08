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

    it('Should BE DEPLOYED', async function () {
        await this.battle.createRoom()
       
        console.log(await this.battle.joinRoom(2))
    })
    
    


})
