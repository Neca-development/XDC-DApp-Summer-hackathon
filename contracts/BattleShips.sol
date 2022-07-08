// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/utils/Strings.sol';

// Import this file to use console.log
enum ResultBattle {
    SHIP_WIN,
    BOAT_WIN,
    PENDING
}

contract BattleShips {
    
    struct Match {
        address ship; 
        address boat; 
        uint8 healthShip;
        uint8 healthBoat;
        ResultBattle result; 
        uint16 roundNumber;
        bytes[] actionShip;
        bytes[] actionBoat;
        bool isStart;
    }


    uint256 private roomId;

    mapping(uint256 => Match) public matches;

    function createRoom()public returns(uint256){
        Match storage session = matches[roomId];
        
        session.ship = msg.sender;
        session.healthShip = 3;
        session.healthBoat = 3;
        session.result = ResultBattle.PENDING;
        session.roundNumber = 0;
        session.isStart = false;

        roomId++;    
        return roomId - 1;
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
    
        
    }

    function confirmMove(uint256 _roomId, bool[] memory confirmParams )public{
        Match storage session = matches[_roomId];

        require(session.ship != address(0), "Incorrect room ID");
        require(msg.sender == session.boat || msg.sender == session.ship, "Incorrect room ID");
        require(confirmParams.length == 3, "Invalid confirm params");

        uint8 validActionNumberBoat;
        uint8 validActionNumberShip;

        bool isValidActionNumberBoat;
        bool isValidActionNumberShip;

        if(session.boat == msg.sender){

            for(uint8 i; i < session.actionBoat.length; i++){
                checkParamsVerification(session.actionBoat[i], concatParams(i, _roomId, confirmParams[i]), msg.sender );
             }

            for(uint8 i; i < session.actionBoat.length; i++){
                if(confirmParams[i]){
                    validActionNumberBoat = i;
                    isValidActionNumberBoat = true;
                }
             }    
        }else{
            for(uint8 i; i < session.actionShip.length; i++){
                checkParamsVerification(session.actionShip[i], concatParams(i, _roomId, confirmParams[i]), msg.sender );
             }

            for(uint8 i; i < session.actionShip.length; i++){
                if(confirmParams[i]){
                    validActionNumberShip = i;
                    isValidActionNumberShip = true;
                }
            }
        }

    if(isValidActionNumberBoat && isValidActionNumberShip){
            nextRound(_roomId, validActionNumberBoat, validActionNumberShip);
        }
       
    }

    function nextRound(uint256 _roomId, uint8 validActionNumberBoat, uint8 validActionNumberShip) private {
        Match storage session = matches[_roomId];

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

            return;
            
        }

        if (session.roundNumber % 2 == 0) { // стреляла лодка
            session.healthShip--;
        } else {
            session.healthBoat--;
        }

        session.roundNumber++;

         if (session.healthBoat == 0 || session.healthShip == 0) {
            emit MatchWasEnded( _roomId, session.healthShip, session.healthBoat, session.roundNumber);
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
        
    }


    function checkParamsVerification(bytes memory _signature, string memory _concatenatedParams, address publicKey) public pure {
		(bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
		require(verifyMessage(_concatenatedParams, v, r, s) == publicKey, 'Your signature is not valid');
	}

	function splitSignature(bytes memory _signature)
		public
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
	) public pure returns (address) {
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
		bool _stateAction
	) public pure returns (string memory) {
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
    event MatchWasStarted(uint256 _roomId, uint16 roundNumber);
    event MatchWasEnded(uint256 _roomId, uint8 healthShip, uint8 healthBoat, uint16 roundNumber);
    event RoundWasEnded(uint256 _roomId, uint8 shipAction, uint8 boatAction, uint8 healthShip, uint8 healthBoat, uint16 roundNumber);
}
