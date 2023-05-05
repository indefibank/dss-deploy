pragma solidity >=0.5.12;

import "./DssDeploy.t.base.sol";

contract DssDeployTest is DssDeployTestBase {
    function testDeploy() public {
        deploy();
    }

    function testFailMissingVat() public {
        dssDeploy.deployTaxation();
    }

    function testFailMissingTaxation() public {
        dssDeploy.deployVat();
        dssDeploy.deployStbl(99);
        dssDeploy.deployAuctions(address(gov));
    }

    function testFailMissingAuctions() public {
        dssDeploy.deployVat();
        dssDeploy.deployTaxation();
        dssDeploy.deployStbl(99);
        dssDeploy.deployLiquidator();
    }

    function testFailMissingLiquidator() public {
        dssDeploy.deployVat();
        dssDeploy.deployStbl(99);
        dssDeploy.deployTaxation();
        dssDeploy.deployAuctions(address(gov));
        dssDeploy.deployShutdown(address(gov), address(0x0), 10);
    }

    function testFailMissingEnd() public {
        dssDeploy.deployVat();
        dssDeploy.deployStbl(99);
        dssDeploy.deployTaxation();
        dssDeploy.deployAuctions(address(gov));
        dssDeploy.deployPause(0, address(authority));
    }

    function testJoinCOIN() public {
        deploy();
        assertEq(vat.gem("COIN", address(this)), 0);
        wcoin.mint(1 ether);
        assertEq(wcoin.balanceOf(address(this)), 1 ether);
        wcoin.approve(address(coinJoin), 1 ether);
        coinJoin.join(address(this), 1 ether);
        assertEq(wcoin.balanceOf(address(this)), 0);
        assertEq(vat.gem("COIN", address(this)), 1 ether);
    }

    function testJoinGem() public {
        deploy();
        col.mint(1 ether);
        assertEq(col.balanceOf(address(this)), 1 ether);
        assertEq(vat.gem("COL", address(this)), 0);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);
        assertEq(col.balanceOf(address(this)), 0);
        assertEq(vat.gem("COL", address(this)), 1 ether);
    }

    function testExitCOIN() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);
        coinJoin.exit(address(this), 1 ether);
        assertEq(vat.gem("COIN", address(this)), 0);
    }

    function testExitGem() public {
        deploy();
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);
        colJoin.exit(address(this), 1 ether);
        assertEq(col.balanceOf(address(this)), 1 ether);
        assertEq(vat.gem("COL", address(this)), 0);
    }

    function testFrobDrawStbl() public {
        deploy();
        assertEq(stbl.balanceOf(address(this)), 0);
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);

        vat.frob("COIN", address(this), address(this), address(this), 0.5 ether, 60 ether);
        assertEq(vat.gem("COIN", address(this)), 0.5 ether);
        assertEq(vat.stbl(address(this)), mul(RAY, 60 ether));

        vat.hope(address(stblJoin));
        stblJoin.exit(address(this), 60 ether);
        assertEq(stbl.balanceOf(address(this)), 60 ether);
        assertEq(vat.stbl(address(this)), 0);
    }

    function testFrobDrawStblGem() public {
        deploy();
        assertEq(stbl.balanceOf(address(this)), 0);
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);

        vat.frob("COL", address(this), address(this), address(this), 0.5 ether, 20 ether);

        vat.hope(address(stblJoin));
        stblJoin.exit(address(this), 20 ether);
        assertEq(stbl.balanceOf(address(this)), 20 ether);
    }

    function testFrobDrawStblLimit() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);
        vat.frob("COIN", address(this), address(this), address(this), 0.5 ether, 100 ether); // 0.5 * 300 / 1.5 = 100 STBL max
    }

    function testFrobDrawStblGemLimit() public {
        deploy();
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);
        vat.frob("COL", address(this), address(this), address(this), 0.5 ether, 20.454545454545454545 ether); // 0.5 * 45 / 1.1 = 20.454545454545454545 STBL max
    }

    function testFailFrobDrawStblLimit() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);
        vat.frob("COIN", address(this), address(this), address(this), 0.5 ether, 100 ether + 1);
    }

    function testFailFrobDrawStblGemLimit() public {
        deploy();
        col.mint(1 ether);
        col.approve(address(colJoin), 1 ether);
        colJoin.join(address(this), 1 ether);
        vat.frob("COL", address(this), address(this), address(this), 0.5 ether, 20.454545454545454545 ether + 1);
    }

    function testFrobPaybackStbl() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);
        vat.frob("COIN", address(this), address(this), address(this), 0.5 ether, 60 ether);
        vat.hope(address(stblJoin));
        stblJoin.exit(address(this), 60 ether);
        assertEq(stbl.balanceOf(address(this)), 60 ether);
        stbl.approve(address(stblJoin), uint(-1));
        stblJoin.join(address(this), 60 ether);
        assertEq(stbl.balanceOf(address(this)), 0);

        assertEq(vat.stbl(address(this)), mul(RAY, 60 ether));
        vat.frob("COIN", address(this), address(this), address(this), 0 ether, -60 ether);
        assertEq(vat.stbl(address(this)), 0);
    }

    function testFrobFromAnotherUser() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);
        vat.hope(address(user1));
        user1.doFrob(address(vat), "COIN", address(this), address(this), address(this), 0.5 ether, 60 ether);
    }

    function testFailFrobDust() public {
        deploy();
        wcoin.mint(100 ether); // Big number just to make sure to avoid unsafe situation
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 100 ether);

        this.file(address(vat), "COIN", "dust", mul(RAY, 20 ether));
        vat.frob("COIN", address(this), address(this), address(this), 100 ether, 19 ether);
    }

    function testFailFrobFromAnotherUser() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);
        user1.doFrob(address(vat), "COIN", address(this), address(this), address(this), 0.5 ether, 60 ether);
    }

    function testFailBite() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);
        vat.frob("COIN", address(this), address(this), address(this), 0.5 ether, 100 ether); // Maximun STBL

        cat.bite("COIN", address(this));
    }

    function testBite() public {
        deploy();
        this.file(address(cat), "COIN", "dunk", rad(200 ether)); // 200 STBL max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 STBL max on auction
        this.file(address(cat), "COIN", "chop", WAD);
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);
        vat.frob("COIN", address(this), address(this), address(this), 1 ether, 200 ether); // Maximun STBL generated

        pipCOIN.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("COIN");

        (uint ink, uint art) = vat.urns("COIN", address(this));
        assertEq(ink, 1 ether);
        assertEq(art, 200 ether);
        cat.bite("COIN", address(this));
        (ink, art) = vat.urns("COIN", address(this));
        assertEq(ink, 0);
        assertEq(art, 0);
    }

    function testBitePartial() public {
        deploy();
        this.file(address(cat), "COIN", "dunk", rad(200 ether)); // 200 STBL max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 STBL max on auction
        this.file(address(cat), "COIN", "chop", WAD);
        wcoin.mint(10 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 10 ether);
        vat.frob("COIN", address(this), address(this), address(this), 10 ether, 2000 ether); // Maximun STBL generated

        pipCOIN.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("COIN");

        (uint ink, uint art) = vat.urns("COIN", address(this));
        assertEq(ink, 10 ether);
        assertEq(art, 2000 ether);
        cat.bite("COIN", address(this));
        (ink, art) = vat.urns("COIN", address(this));
        assertEq(ink, 9 ether);
        assertEq(art, 1800 ether);
    }

    function testFlip() public {
        deploy();
        this.file(address(cat), "COIN", "dunk", rad(200 ether)); // 200 STBL max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 STBL max on auction
        this.file(address(cat), "COIN", "chop", WAD);
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);
        vat.frob("COIN", address(this), address(this), address(this), 1 ether, 200 ether); // Maximun STBL generated
        pipCOIN.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("COIN");
        assertEq(vat.gem("COIN", address(coinFlip)), 0);
        uint batchId = cat.bite("COIN", address(this));
        assertEq(vat.gem("COIN", address(coinFlip)), 1 ether);
        wcoin.mint(10 ether);
        wcoin.transfer(address(user1), 10 ether);
        user1.doWcoinJoin(address(wcoin), address(coinJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "COIN", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        wcoin.mint(10 ether);
        wcoin.transfer(address(user2), 10 ether);
        user2.doWcoinJoin(address(wcoin), address(coinJoin), address(user2), 10 ether);
        user2.doFrob(address(vat), "COIN", address(user2), address(user2), address(user2), 10 ether, 1000 ether);

        user1.doHope(address(vat), address(coinFlip));
        user2.doHope(address(vat), address(coinFlip));

        user1.doTend(address(coinFlip), batchId, 1 ether, rad(100 ether));
        user2.doTend(address(coinFlip), batchId, 1 ether, rad(140 ether));
        user1.doTend(address(coinFlip), batchId, 1 ether, rad(180 ether));
        user2.doTend(address(coinFlip), batchId, 1 ether, rad(200 ether));

        user1.doDent(address(coinFlip), batchId, 0.8 ether, rad(200 ether));
        user2.doDent(address(coinFlip), batchId, 0.7 ether, rad(200 ether));
        hevm.warp(coinFlip.ttl() - 1);
        user1.doDent(address(coinFlip), batchId, 0.6 ether, rad(200 ether));
        hevm.warp(now + coinFlip.ttl() + 1);
        user1.doDeal(address(coinFlip), batchId);
    }

    function _flop() internal returns (uint batchId) {
        this.file(address(cat), "COIN", "dunk", rad(200 ether)); // 200 STBL max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 STBL max on auction
        this.file(address(cat), "COIN", "chop", WAD);
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);
        vat.frob("COIN", address(this), address(this), address(this), 1 ether, 200 ether); // Maximun STBL generated
        pipCOIN.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("COIN");
        uint48 eraBite = uint48(now);
        batchId = cat.bite("COIN", address(this));
        wcoin.mint(10 ether);
        wcoin.transfer(address(user1), 10 ether);
        user1.doWcoinJoin(address(wcoin), address(coinJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "COIN", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        wcoin.mint(10 ether);
        wcoin.transfer(address(user2), 10 ether);
        user2.doWcoinJoin(address(wcoin), address(coinJoin), address(user2), 10 ether);
        user2.doFrob(address(vat), "COIN", address(user2), address(user2), address(user2), 10 ether, 1000 ether);

        user1.doHope(address(vat), address(coinFlip));
        user2.doHope(address(vat), address(coinFlip));

        user1.doTend(address(coinFlip), batchId, 1 ether, rad(100 ether));
        user2.doTend(address(coinFlip), batchId, 1 ether, rad(140 ether));
        user1.doTend(address(coinFlip), batchId, 1 ether, rad(180 ether));

        hevm.warp(now + coinFlip.ttl() + 1);
        user1.doDeal(address(coinFlip), batchId);

        vow.flog(eraBite);
        vow.heal(rad(180 ether));
        this.file(address(vow), "dump", 0.65 ether);
        this.file(address(vow), bytes32("sump"), rad(20 ether));
        batchId = vow.flop();
        (uint bid,,,,) = flop.bids(batchId);
        assertEq(bid, rad(20 ether));
        user1.doHope(address(vat), address(flop));
        user2.doHope(address(vat), address(flop));
    }

    function testFlop() public {
        deploy();
        uint batchId = _flop();
        user1.doDent(address(flop), batchId, 0.6 ether, rad(20 ether));
        hevm.warp(now + flop.ttl() - 1);
        user2.doDent(address(flop), batchId, 0.2 ether, rad(20 ether));
        user1.doDent(address(flop), batchId, 0.16 ether, rad(20 ether));
        hevm.warp(now + flop.ttl() + 1);
        uint prevGovSupply = gov.totalSupply();
        user1.doDeal(address(flop), batchId);
        assertEq(gov.totalSupply(), prevGovSupply + 0.16 ether);
        assertEq(vat.stbl(address(vow)), 0);
        assertEq(vat.sin(address(vow)) - vow.Sin() - vow.Ash(), 0);
        assertEq(vat.sin(address(vow)), 0);
    }

    function _flap() internal returns (uint batchId) {
        this.dripAndFile(address(jug), bytes32("COIN"), bytes32("duty"), uint(1.05 * 10 ** 27));
        wcoin.mint(0.5 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 0.5 ether);
        vat.frob("COIN", address(this), address(this), address(this), 0.1 ether, 10 ether);
        hevm.warp(now + 1);
        assertEq(vat.stbl(address(vow)), 0);
        jug.drip("COIN");
        assertEq(vat.stbl(address(vow)), rad(10 * 0.05 ether));
        this.file(address(vow), bytes32("bump"), rad(0.05 ether));
        this.file(address(flap), "lid", rad(0.05 ether));
        batchId = vow.flap();

        (,uint lot,,,) = flap.bids(batchId);
        assertEq(lot, rad(0.05 ether));
        user1.doApprove(address(gov), address(flap));
        user2.doApprove(address(gov), address(flap));
        gov.transfer(address(user1), 1 ether);
        gov.transfer(address(user2), 1 ether);

        assertEq(stbl.balanceOf(address(user1)), 0);
        assertEq(gov.balanceOf(address(0)), 0);
    }

    function testFlap() public {
        deploy();
        uint batchId = _flap();
        user1.doTend(address(flap), batchId, rad(0.05 ether), 0.001 ether);
        user2.doTend(address(flap), batchId, rad(0.05 ether), 0.0015 ether);
        user1.doTend(address(flap), batchId, rad(0.05 ether), 0.0016 ether);

        assertEq(gov.balanceOf(address(user1)), 1 ether - 0.0016 ether);
        assertEq(gov.balanceOf(address(user2)), 1 ether);
        hevm.warp(now + flap.ttl() + 1);
        assertEq(gov.balanceOf(address(flap)), 0.0016 ether);
        user1.doDeal(address(flap), batchId);
        assertEq(gov.balanceOf(address(flap)), 0);
        user1.doHope(address(vat), address(stblJoin));
        user1.doStblExit(address(stblJoin), address(user1), 0.05 ether);
        assertEq(stbl.balanceOf(address(user1)), 0.05 ether);
    }

    function testEnd() public {
        deploy();
        this.file(address(cat), "COIN", "dunk", rad(200 ether)); // 200 STBL max per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 STBL max on auction
        this.file(address(cat), "COIN", "chop", WAD);
        wcoin.mint(2 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 2 ether);
        vat.frob("COIN", address(this), address(this), address(this), 2 ether, 400 ether); // Maximun STBL generated
        pipCOIN.poke(bytes32(uint(300 * 10 ** 18 - 1))); // Decrease price in 1 wei
        spotter.poke("COIN");
        uint batchId = cat.bite("COIN", address(this)); // The CDP remains unsafe after 1st batch is bitten
        wcoin.mint(10 ether);
        wcoin.transfer(address(user1), 10 ether);
        user1.doWcoinJoin(address(wcoin), address(coinJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "COIN", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        col.mint(100 ether);
        col.approve(address(colJoin), 100 ether);
        colJoin.join(address(user2), 100 ether);
        user2.doFrob(address(vat), "COL", address(user2), address(user2), address(user2), 100 ether, 1000 ether);

        user1.doHope(address(vat), address(coinFlip));
        user2.doHope(address(vat), address(coinFlip));

        user1.doTend(address(coinFlip), batchId, 1 ether, rad(100 ether));
        user2.doTend(address(coinFlip), batchId, 1 ether, rad(140 ether));
        assertEq(vat.stbl(address(user2)), rad(860 ether));

        this.cage(address(end));
        end.cage("COIN");
        end.cage("COL");

        (uint ink, uint art) = vat.urns("COIN", address(this));
        assertEq(ink, 1 ether);
        assertEq(art, 200 ether);

        end.skip("COIN", batchId);
        assertEq(vat.stbl(address(user2)), rad(1000 ether));
        (ink, art) = vat.urns("COIN", address(this));
        assertEq(ink, 2 ether);
        assertEq(art, 400 ether);

        end.skim("COIN", address(this));
        (ink, art) = vat.urns("COIN", address(this));
        uint remainInkVal = 2 ether - 400 * end.tag("COIN") / 10 ** 9; // 2 COIN (deposited) - 400 STBL debt * COIN cage price
        assertEq(ink, remainInkVal);
        assertEq(art, 0);

        end.free("COIN");
        (ink,) = vat.urns("COIN", address(this));
        assertEq(ink, 0);

        (ink, art) = vat.urns("COIN", address(user1));
        assertEq(ink, 10 ether);
        assertEq(art, 1000 ether);

        end.skim("COIN", address(user1));
        end.skim("COL", address(user2));

        vow.heal(vat.stbl(address(vow)));

        end.thaw();

        end.flow("COIN");
        end.flow("COL");

        vat.hope(address(end));
        end.pack(400 ether);

        assertEq(vat.gem("COIN", address(this)), remainInkVal);
        assertEq(vat.gem("COL", address(this)), 0);
        end.cash("COIN", 400 ether);
        end.cash("COL", 400 ether);
        assertEq(vat.gem("COIN", address(this)), remainInkVal + 400 * end.fix("COIN") / 10 ** 9);
        assertEq(vat.gem("COL", address(this)), 400 * end.fix("COL") / 10 ** 9);
    }

    function testFlopEnd() public {
        deploy();
        uint batchId = _flop();
        this.cage(address(end));
        flop.yank(batchId);
    }

    function testFlopEndWithBid() public {
        deploy();
        uint batchId = _flop();
        user1.doDent(address(flop), batchId, 0.6 ether, rad(20 ether));
        assertEq(vat.stbl(address(user1)), rad(800 ether));
        this.cage(address(end));
        flop.yank(batchId);
        assertEq(vat.stbl(address(user1)), rad(820 ether));
    }

    function testFlapEnd() public {
        deploy();
        uint batchId = _flap();

        this.cage(address(end));
        flap.yank(batchId);
    }

    function testFlapEndWithBid() public {
        deploy();
        uint batchId = _flap();

        user1.doTend(address(flap), batchId, rad(0.05 ether), 0.001 ether);
        assertEq(gov.balanceOf(address(user1)), 1 ether - 0.001 ether);

        this.cage(address(end));
        flap.yank(batchId);

        assertEq(gov.balanceOf(address(user1)), 1 ether);
    }

    function testFireESM() public {
        deploy();
        gov.mint(address(user1), 10);

        user1.doESMJoin(address(gov), address(esm), 10);
        esm.fire();
    }

    function testDsr() public {
        deploy();
        this.dripAndFile(address(jug), bytes32("COIN"), bytes32("duty"), uint(1.1 * 10 ** 27));
        this.dripAndFile(address(pot), "dsr", uint(1.05 * 10 ** 27));
        wcoin.mint(0.5 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 0.5 ether);
        vat.frob("COIN", address(this), address(this), address(this), 0.1 ether, 10 ether);
        assertEq(vat.stbl(address(this)), mul(10 ether, RAY));
        vat.hope(address(pot));
        pot.join(10 ether);
        hevm.warp(now + 1);
        jug.drip("COIN");
        pot.drip();
        pot.exit(10 ether);
        assertEq(vat.stbl(address(this)), mul(10.5 ether, RAY));
    }

    function testFork() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);

        vat.frob("COIN", address(this), address(this), address(this), 1 ether, 60 ether);
        (uint ink, uint art) = vat.urns("COIN", address(this));
        assertEq(ink, 1 ether);
        assertEq(art, 60 ether);

        user1.doHope(address(vat), address(this));
        vat.fork("COIN", address(this), address(user1), 0.25 ether, 15 ether);

        (ink, art) = vat.urns("COIN", address(this));
        assertEq(ink, 0.75 ether);
        assertEq(art, 45 ether);

        (ink, art) = vat.urns("COIN", address(user1));
        assertEq(ink, 0.25 ether);
        assertEq(art, 15 ether);
    }

    function testFailFork() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);

        vat.frob("COIN", address(this), address(this), address(this), 1 ether, 60 ether);

        vat.fork("COIN", address(this), address(user1), 0.25 ether, 15 ether);
    }

    function testForkFromOtherUsr() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);

        vat.frob("COIN", address(this), address(this), address(this), 1 ether, 60 ether);

        vat.hope(address(user1));
        user1.doFork(address(vat), "COIN", address(this), address(user1), 0.25 ether, 15 ether);
    }

    function testFailForkFromOtherUsr() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);

        vat.frob("COIN", address(this), address(this), address(this), 1 ether, 60 ether);

        user1.doFork(address(vat), "COIN", address(this), address(user1), 0.25 ether, 15 ether);
    }

    function testFailForkUnsafeSrc() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);

        vat.frob("COIN", address(this), address(this), address(this), 1 ether, 60 ether);
        vat.fork("COIN", address(this), address(user1), 0.9 ether, 1 ether);
    }

    function testFailForkUnsafeDst() public {
        deploy();
        wcoin.mint(1 ether);
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 1 ether);

        vat.frob("COIN", address(this), address(this), address(this), 1 ether, 60 ether);
        vat.fork("COIN", address(this), address(user1), 0.1 ether, 59 ether);
    }

    function testFailForkDustSrc() public {
        deploy();
        wcoin.mint(100 ether); // Big number just to make sure to avoid unsafe situation
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 100 ether);

        this.file(address(vat), "COIN", "dust", mul(RAY, 20 ether));
        vat.frob("COIN", address(this), address(this), address(this), 100 ether, 60 ether);

        user1.doHope(address(vat), address(this));
        vat.fork("COIN", address(this), address(user1), 50 ether, 19 ether);
    }

    function testFailForkDustDst() public {
        deploy();
        wcoin.mint(100 ether); // Big number just to make sure to avoid unsafe situation
        wcoin.approve(address(coinJoin), uint(-1));
        coinJoin.join(address(this), 100 ether);

        this.file(address(vat), "COIN", "dust", mul(RAY, 20 ether));
        vat.frob("COIN", address(this), address(this), address(this), 100 ether, 60 ether);

        user1.doHope(address(vat), address(this));
        vat.fork("COIN", address(this), address(user1), 50 ether, 41 ether);
    }

    function testSetPauseAuthority() public {
        deploy();
        assertEq(address(pause.authority()), address(authority));
        this.setAuthority(address(123));
        assertEq(address(pause.authority()), address(123));
    }

    function testSetPauseDelay() public {
        deploy();
        assertEq(pause.delay(), 0);
        this.setDelay(5);
        assertEq(pause.delay(), 5);
    }

    function testSetPauseAuthorityAndDelay() public {
        deploy();
        assertEq(address(pause.authority()), address(authority));
        assertEq(pause.delay(), 0);
        this.setAuthorityAndDelay(address(123), 5);
        assertEq(address(pause.authority()), address(123));
        assertEq(pause.delay(), 5);
    }

    function testAuth() public {
        deployKeepAuth();

        // vat
        assertEq(vat.wards(address(dssDeploy)), 1);
        assertEq(vat.wards(address(coinJoin)), 1);
        assertEq(vat.wards(address(colJoin)), 1);
        assertEq(vat.wards(address(cat)), 1);
        assertEq(vat.wards(address(jug)), 1);
        assertEq(vat.wards(address(spotter)), 1);
        assertEq(vat.wards(address(end)), 1);
        assertEq(vat.wards(address(pause.proxy())), 1);

        // cat
        assertEq(cat.wards(address(dssDeploy)), 1);
        assertEq(cat.wards(address(end)), 1);
        assertEq(cat.wards(address(pause.proxy())), 1);

        // vow
        assertEq(vow.wards(address(dssDeploy)), 1);
        assertEq(vow.wards(address(cat)), 1);
        assertEq(vow.wards(address(end)), 1);
        assertEq(vow.wards(address(pause.proxy())), 1);

        // jug
        assertEq(jug.wards(address(dssDeploy)), 1);
        assertEq(jug.wards(address(pause.proxy())), 1);

        // pot
        assertEq(pot.wards(address(dssDeploy)), 1);
        assertEq(pot.wards(address(pause.proxy())), 1);

        // stbl
        assertEq(stbl.wards(address(dssDeploy)), 1);

        // spotter
        assertEq(spotter.wards(address(dssDeploy)), 1);
        assertEq(spotter.wards(address(pause.proxy())), 1);

        // flap
        assertEq(flap.wards(address(dssDeploy)), 1);
        assertEq(flap.wards(address(vow)), 1);
        assertEq(flap.wards(address(pause.proxy())), 1);

        // flop
        assertEq(flop.wards(address(dssDeploy)), 1);
        assertEq(flop.wards(address(vow)), 1);
        assertEq(flop.wards(address(pause.proxy())), 1);

        // end
        assertEq(end.wards(address(dssDeploy)), 1);
        assertEq(end.wards(address(esm)), 1);
        assertEq(end.wards(address(pause.proxy())), 1);

        // flips
        assertEq(coinFlip.wards(address(dssDeploy)), 1);
        assertEq(coinFlip.wards(address(end)), 1);
        assertEq(coinFlip.wards(address(pause.proxy())), 1);
        assertEq(colFlip.wards(address(dssDeploy)), 1);
        assertEq(colFlip.wards(address(end)), 1);
        assertEq(colFlip.wards(address(pause.proxy())), 1);

        // pause
        assertEq(address(pause.authority()), address(authority));
        assertEq(pause.owner(), address(0));

        // dssDeploy
        assertEq(address(dssDeploy.authority()), address(0));
        assertEq(dssDeploy.owner(), address(this));

        dssDeploy.releaseAuth();
        dssDeploy.releaseAuthFlip("COIN");
        dssDeploy.releaseAuthFlip("COL");
        assertEq(vat.wards(address(dssDeploy)), 0);
        assertEq(cat.wards(address(dssDeploy)), 0);
        assertEq(vow.wards(address(dssDeploy)), 0);
        assertEq(jug.wards(address(dssDeploy)), 0);
        assertEq(pot.wards(address(dssDeploy)), 0);
        assertEq(stbl.wards(address(dssDeploy)), 0);
        assertEq(spotter.wards(address(dssDeploy)), 0);
        assertEq(flap.wards(address(dssDeploy)), 0);
        assertEq(flop.wards(address(dssDeploy)), 0);
        assertEq(end.wards(address(dssDeploy)), 0);
        assertEq(coinFlip.wards(address(dssDeploy)), 0);
        assertEq(colFlip.wards(address(dssDeploy)), 0);
    }
}
