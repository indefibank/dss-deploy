// SPDX-License-Identifier: AGPL-3.0-or-later

/// DssDeploy.sol

// Copyright (C) 2018-2020 Maker Ecosystem Growth Holdings, INC.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity >=0.5.12;

import {DSAuth, DSAuthority} from "ds-auth/auth.sol";
import {DSPause} from "ds-pause/pause.sol";

import {Vat} from "dss/vat.sol";
import {Jug} from "dss/jug.sol";
import {Vow} from "dss/vow.sol";
import {Cat} from "dss/cat.sol";
import {StblJoin} from "dss/join.sol";
import {Flapper} from "dss/flap.sol";
import {Flopper} from "dss/flop.sol";
import {Flipper} from "dss/flip.sol";
import {StableCoin} from "dss/StableCoin.sol";
import {End} from "dss/end.sol";
import {ESM} from "esm/ESM.sol";
import {Pot} from "dss/pot.sol";
import {Spotter} from "dss/spot.sol";

contract VatFab {
    function newVat(address owner) public returns (Vat vat) {
        vat = new Vat();
        vat.rely(owner);
        vat.deny(address(this));
    }
}

contract JugFab {
    function newJug(address owner, address vat) public returns (Jug jug) {
        jug = new Jug(vat);
        jug.rely(owner);
        jug.deny(address(this));
    }
}

contract VowFab {
    function newVow(address owner, address vat, address flap, address flop) public returns (Vow vow) {
        vow = new Vow(vat, flap, flop);
        vow.rely(owner);
        vow.deny(address(this));
    }
}

contract CatFab {
    function newCat(address owner, address vat) public returns (Cat cat) {
        cat = new Cat(vat);
        cat.rely(owner);
        cat.deny(address(this));
    }
}

contract StblFab {
    function newStbl(address owner, uint chainId) public returns (StableCoin stbl) {
        stbl = new StableCoin(chainId);
        stbl.rely(owner);
        stbl.deny(address(this));
    }
}

contract StblJoinFab {
    function newStblJoin(address vat, address stbl) public returns (StblJoin stblJoin) {
        stblJoin = new StblJoin(vat, stbl);
    }
}

contract FlapFab {
    function newFlap(address owner, address vat, address gov) public returns (Flapper flap) {
        flap = new Flapper(vat, gov);
        flap.rely(owner);
        flap.deny(address(this));
    }
}

contract FlopFab {
    function newFlop(address owner, address vat, address gov) public returns (Flopper flop) {
        flop = new Flopper(vat, gov);
        flop.rely(owner);
        flop.deny(address(this));
    }
}

contract FlipFab {
    function newFlip(address owner, address vat, address cat, bytes32 ilk) public returns (Flipper flip) {
        flip = new Flipper(vat, cat, ilk);
        flip.rely(owner);
        flip.deny(address(this));
    }
}

contract SpotFab {
    function newSpotter(address owner, address vat) public returns (Spotter spotter) {
        spotter = new Spotter(vat);
        spotter.rely(owner);
        spotter.deny(address(this));
    }
}

contract PotFab {
    function newPot(address owner, address vat) public returns (Pot pot) {
        pot = new Pot(vat);
        pot.rely(owner);
        pot.deny(address(this));
    }
}

contract EndFab {
    function newEnd(address owner) public returns (End end) {
        end = new End();
        end.rely(owner);
        end.deny(address(this));
    }
}

contract ESMFab {
    function newESM(address gov, address end, address pit, uint min) public returns (ESM esm) {
        esm = new ESM(gov, end, pit, min);
    }
}

contract PauseFab {
    function newPause(uint delay, address owner, address authority) public returns(DSPause pause) {
        pause = new DSPause(delay, owner, authority);
    }
}

contract DssDeploy is DSAuth {
    VatFab     public vatFab;
    JugFab     public jugFab;
    VowFab     public vowFab;
    CatFab     public catFab;
    StblFab     public stblFab;
    StblJoinFab public stblJoinFab;
    FlapFab    public flapFab;
    FlopFab    public flopFab;
    FlipFab    public flipFab;
    SpotFab    public spotFab;
    PotFab     public potFab;
    EndFab     public endFab;
    ESMFab     public esmFab;
    PauseFab   public pauseFab;

    Vat     public vat;
    Jug     public jug;
    Vow     public vow;
    Cat     public cat;
    StableCoin     public stbl;
    StblJoin public stblJoin;
    Flapper public flap;
    Flopper public flop;
    Spotter public spotter;
    Pot     public pot;
    End     public end;
    ESM     public esm;
    DSPause public pause;

    mapping(bytes32 => Ilk) public ilks;

    uint8 public step = 0;

    uint256 constant ONE = 10 ** 27;

    struct Ilk {
        Flipper flip;
        address join;
    }

    constructor(
        VatFab vatFab_,
        JugFab jugFab_,
        VowFab vowFab_,
        CatFab catFab_,
        StblFab stblFab_,
        StblJoinFab stblJoinFab_,
        FlapFab flapFab_,
        FlopFab flopFab_,
        FlipFab flipFab_,
        SpotFab spotFab_,
        PotFab potFab_,
        EndFab endFab_,
        ESMFab esmFab_,
        PauseFab pauseFab_
    ) public {
        vatFab = vatFab_;
        jugFab = jugFab_;
        vowFab = vowFab_;
        catFab = catFab_;
        stblFab = stblFab_;
        stblJoinFab = stblJoinFab_;
        flapFab = flapFab_;
        flopFab = flopFab_;
        flipFab = flipFab_;
        spotFab = spotFab_;
        potFab = potFab_;
        endFab = endFab_;
        esmFab = esmFab_;
        pauseFab = pauseFab_;
    }

    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }

    function deployVat() public auth {
        require(address(vat) == address(0), "VAT already deployed");
        vat = vatFab.newVat(address(this));
        spotter = spotFab.newSpotter(address(this), address(vat));

        // Internal auth
        vat.rely(address(spotter));
    }

    function deployStbl(uint256 chainId) public auth {
        require(address(vat) != address(0), "Missing previous step");

        // Deploy
        stbl = stblFab.newStbl(address(this), chainId);
        stblJoin = stblJoinFab.newStblJoin(address(vat), address(stbl));
        stbl.rely(address(stblJoin));
    }

    function deployTaxation() public auth {
        require(address(vat) != address(0), "Missing previous step");

        // Deploy
        jug = jugFab.newJug(address(this), address(vat));
        pot = potFab.newPot(address(this), address(vat));

        // Internal auth
        vat.rely(address(jug));
        vat.rely(address(pot));
    }

    function deployAuctions(address gov) public auth {
        require(gov != address(0), "Missing GOV address");
        require(address(jug) != address(0), "Missing previous step");

        // Deploy
        flap = flapFab.newFlap(address(this), address(vat), gov);
        flop = flopFab.newFlop(address(this), address(vat), gov);
        vow = vowFab.newVow(address(this), address(vat), address(flap), address(flop));

        // Internal references set up
        jug.file("vow", address(vow));
        pot.file("vow", address(vow));

        // Internal auth
        vat.rely(address(flop));
        flap.rely(address(vow));
        flop.rely(address(vow));
    }

    function deployLiquidator() public auth {
        require(address(vow) != address(0), "Missing previous step");

        // Deploy
        cat = catFab.newCat(address(this), address(vat));

        // Internal references set up
        cat.file("vow", address(vow));

        // Internal auth
        vat.rely(address(cat));
        vow.rely(address(cat));
    }

    function deployShutdown(address gov, address pit, uint256 min) public auth {
        require(address(cat) != address(0), "Missing previous step");

        // Deploy
        end = endFab.newEnd(address(this));

        // Internal references set up
        end.file("vat", address(vat));
        end.file("cat", address(cat));
        end.file("vow", address(vow));
        end.file("pot", address(pot));
        end.file("spot", address(spotter));

        // Internal auth
        vat.rely(address(end));
        cat.rely(address(end));
        vow.rely(address(end));
        pot.rely(address(end));
        spotter.rely(address(end));

        // Deploy ESM
        esm = esmFab.newESM(gov, address(end), address(pit), min);
        end.rely(address(esm));
    }

    function deployPause(uint delay, address authority) public auth {
        require(address(stbl) != address(0), "Missing previous step");
        require(address(end) != address(0), "Missing previous step");

        pause = pauseFab.newPause(delay, address(0), authority);

        vat.rely(address(pause.proxy()));
        cat.rely(address(pause.proxy()));
        vow.rely(address(pause.proxy()));
        jug.rely(address(pause.proxy()));
        pot.rely(address(pause.proxy()));
        spotter.rely(address(pause.proxy()));
        flap.rely(address(pause.proxy()));
        flop.rely(address(pause.proxy()));
        end.rely(address(pause.proxy()));
    }

    function deployCollateral(bytes32 ilk, address join, address pip) public auth {
        require(ilk != bytes32(""), "Missing ilk name");
        require(join != address(0), "Missing join address");
        require(pip != address(0), "Missing pip address");
        require(address(pause) != address(0), "Missing previous step");

        // Deploy
        ilks[ilk].flip = flipFab.newFlip(address(this), address(vat), address(cat), ilk);
        ilks[ilk].join = join;
        Spotter(spotter).file(ilk, "pip", address(pip)); // Set pip

        // Internal references set up
        cat.file(ilk, "flip", address(ilks[ilk].flip));
        vat.init(ilk);
        jug.init(ilk);

        // Internal auth
        vat.rely(join);
        cat.rely(address(ilks[ilk].flip));
        ilks[ilk].flip.rely(address(cat));
        ilks[ilk].flip.rely(address(end));
        ilks[ilk].flip.rely(address(pause.proxy()));
    }

    function releaseAuth() public auth {
        vat.deny(address(this));
        cat.deny(address(this));
        vow.deny(address(this));
        jug.deny(address(this));
        pot.deny(address(this));
        stbl.deny(address(this));
        spotter.deny(address(this));
        flap.deny(address(this));
        flop.deny(address(this));
        end.deny(address(this));
    }

    function releaseAuthFlip(bytes32 ilk) public auth {
        ilks[ilk].flip.deny(address(this));
    }
}
