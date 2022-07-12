// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/utils/Strings.sol';

// Import this file to use console.log


contract BattleShips {
    
    struct Match {
        address ship; 
        address boat; 
        uint8 healthShip;
        uint8 healthBoat;
        uint16 roundNumber;
        bytes[] actionShip;
        bytes[] actionBoat;
        bool[3] destroyedPartsShip;
        bool[3] destroyedPartsBoat;
        bool isStart;
        uint8 lastMoveBoat;
        uint8 lastMoveShip;
    }


    uint256 private roomId;

    mapping(uint256 => Match) public matches;

    function createRoom()public{
        Match storage session = matches[roomId];
        
        session.ship = msg.sender;
        session.healthShip = 3;
        session.healthBoat = 3;
        session.roundNumber = 0;
        session.isStart = false;
        session.lastMoveBoat = 4;
        session.lastMoveShip = 4;
        session.destroyedPartsShip = [false, false, false];
        session.destroyedPartsBoat = [false, false, false];

        emit RoomCreated(roomId);

        roomId++;    

    }

    function joinRoom(uint256 _roomId) public {
        Match storage session = matches[_roomId];
        require(session.ship != address(0), "Incorrect room ID");
        require(!session.isStart, "Match already start");

        session.boat = msg.sender;
        session.isStart = true;
        session.roundNumber++;

        emit MatchWasStarted(_roomId, session.roundNumber);
    }


    function doMove(uint256 _roomId, bytes[] memory signatures)public {
        Match storage session = matches[_roomId];
        
        require(session.ship != address(0), "Incorrect room ID");
        require(msg.sender == session.boat || msg.sender == session.ship, "Incorrect room ID");
    
        if(msg.sender == session.boat && session.actionBoat.length == 0){
            session.actionBoat = signatures;
        }else if(session.actionShip.length == 0){
            session.actionShip = signatures;
        }else{
            revert("Move already set! Wait next round");
        }
        emit Moved(_roomId);
        
    }

    function confirmMove(uint256 _roomId, string[3] memory confirmParams )public{
        Match storage session = matches[_roomId];

        require(session.ship != address(0), "Incorrect room ID");
        require(msg.sender == session.boat || msg.sender == session.ship, "Incorrect room ID");
        require(confirmParams.length == 3, "Invalid confirm params");

    

        if(session.boat == msg.sender){

            for(uint8 i; i < confirmParams.length; i++){
                checkParamsVerification(session.actionBoat[i], confirmParams[i], msg.sender );
             }

            for(uint8 i; i < session.actionBoat.length; i++){

                bytes memory conPar = bytes(confirmParams[i]);
                
                if(conPar[conPar.length-1] == 0x54 ){
                    session.lastMoveBoat = i;
                }
             }    
        }else{
            for(uint8 i; i < session.actionShip.length; i++){
                checkParamsVerification(session.actionShip[i], confirmParams[i], msg.sender );
             }

            for(uint8 i; i < session.actionShip.length; i++){
                bytes memory conPar = bytes(confirmParams[i]);

                if(conPar[conPar.length-1] == 0x54 ){
                    
                    session.lastMoveShip = i;
                }
            }
        }

    if(session.lastMoveBoat != 4 && session.lastMoveShip != 4){
            
            nextRound(_roomId, session.lastMoveBoat, session.lastMoveShip);
        }
       
    }

    function nextRound(uint256 _roomId, uint8 validActionNumberBoat, uint8 validActionNumberShip) private {
        Match storage session = matches[_roomId];
        bytes[] memory clearAction;

        if(validActionNumberBoat == validActionNumberShip){
            session.roundNumber++;
            
            emit RoundWasEnded(
                _roomId,
                validActionNumberShip,
                validActionNumberBoat,
                session.healthShip,
                session.healthBoat,
                session.roundNumber
            );

            session.actionBoat = clearAction;
            session.actionShip = clearAction;
            session.lastMoveBoat = 4;
            session.lastMoveShip = 4;

            return;
            
        }
        
        if (session.roundNumber % 2 == 0) { 
            session.healthShip--;
            session.destroyedPartsShip[validActionNumberBoat] = true;
            
        } else {
            session.healthBoat--;
            session.destroyedPartsBoat[validActionNumberShip] = true;
        }

        session.roundNumber++;

         if (session.healthBoat == 0 || session.healthShip == 0) {
            emit MatchWasEnded( _roomId, session.healthShip, session.healthBoat, session.roundNumber);
            session.isStart = false;
        } else {
            emit RoundWasEnded(
                _roomId,
                validActionNumberShip,
                validActionNumberBoat,
                session.healthShip,
                session.healthBoat,
                session.roundNumber
            );

        }
            session.actionBoat = clearAction;
            session.actionShip = clearAction;
            session.lastMoveBoat = 4;
            session.lastMoveShip = 4;
    }

    function getDestroyedParts(uint256 _roomId)public view returns(bool[3][2] memory){
        Match storage session = matches[_roomId];
        
        return [session.destroyedPartsShip, session.destroyedPartsBoat];
    }

    function checkParamsVerification(bytes memory _signature, string memory _concatenatedParams, address publicKey) public pure {
		(bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
		require(verifyMessage(_concatenatedParams, v, r, s) == publicKey, 'Your signature is not valid');
	}

	function splitSignature(bytes memory _signature)
		private
		pure
		returns (
			bytes32 r,
			bytes32 s,
			uint8 v
		)
	{
		require(_signature.length == 65, 'invalid signature length');
		assembly {
			r := mload(add(_signature, 32))
			s := mload(add(_signature, 64))
			v := byte(0, mload(add(_signature, 96)))
		}
	}

	function verifyMessage(
		string memory _concatenatedParams,
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	) private pure returns (address) {
		return
			ecrecover(
				keccak256(
					abi.encodePacked(
						'\x19Ethereum Signed Message:\n',
						Strings.toString(bytes(_concatenatedParams).length),
						_concatenatedParams
					)
				),
				_v,
				_r,
				_s
			);
	}

	function concatParams(
		uint256 _action,
		uint256 _roomId,
		string memory _stateAction
	) private pure returns (string memory) {
		return
			string(
				abi.encodePacked(
					Strings.toString(_action),
					Strings.toString(_roomId),
					_stateAction
				)
			);
	}

    /*----------------------------------------EVENTS---------------------------------------------------------*/
    event RoomCreated(uint256 _roomId );
    event Moved(uint256 _roomId);
    event MatchWasStarted(uint256 _roomId, uint16 roundNumber);
    event MatchWasEnded(uint256 _roomId, uint8 healthShip, uint8 healthBoat, uint16 roundNumber);
    event RoundWasEnded(uint256 _roomId, uint8 shipAction, uint8 boatAction, uint8 healthShip, uint8 healthBoat, uint16 roundNumber);
}
