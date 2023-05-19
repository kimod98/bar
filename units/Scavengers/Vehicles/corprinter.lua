return {
	corprinter = {
		acceleration = 0.02547,
		brakerate = 0.05093,
		buildcostenergy = 6600,
		buildcostmetal = 330,
		buildpic = "CORFORGE.DDS",
		buildtime = 10250,
		builddistance = 150,
		builder = true,
		canmove = true,
		category = "ALL TANK MOBILE WEAPON NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE EMPABLE",
		collisionvolumeoffsets = "0 -1 0",
		collisionvolumescales = "36 22 38",
		collisionvolumetype = "Box",
		corpse = "DEAD",
		explodeas = "mediumexplosiongeneric",
		footprintx = 3,
		footprintz = 3,
		idleautoheal = 5,
		idletime = 1800,
		leavetracks = true,
		maxdamage = 5125, 
		maxvelocity = 1.4,
		maxwaterdepth = 0,
		movementclass = "TANK3",
		nochasecategory = "NOTLAND VTOL",
		objectname = "Units/CORPRINTERV4.s3o",
		script = "Units/scavboss/CORPRINTER.cob",
		seismicsignature = 0,
		selfdestructas = "mediumExplosionGenericSelfd",
		sightdistance = 500,
		terraformspeed = 1250,
		trackoffset = 8,
		trackstrength = 8,
		tracktype = "corwidetracks",
		trackwidth = 31,
		turninplace = true,
		turninplaceanglelimit = 90,
		turninplacespeedlimit = 1.287,
		turnrate = 363,
		workertime = 200,
		customparams = {
			unitgroup = 'buildert2',
			model_author = "MASHUP, Itanthias, name inspired by Themitri",
			normaltex = "unittextures/cor_normal.dds",
			subfolder = "corvehicles/t2",
			techlevel = 2,
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "-2.2791595459 -0.365720275879 -0.110244750977",
				collisionvolumescales = "41.4731445313 24.6765594482 38.8007202148",
				collisionvolumetype = "Box",
				damage = 450,
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				height = 20,
				hitdensity = 100,
				metal = 138,
				object = "Units/scavboss/CORFORGE_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				collisionvolumescales = "35.0 4.0 6.0",
				collisionvolumetype = "cylY",
				damage = 350,
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 55,
				object = "Units/cor2X2B.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = {
			pieceexplosiongenerators = {
				[1] = "deathceg2",
				[2] = "deathceg3",
				[3] = "deathceg4",
			},
		},
		sounds = {
			canceldestruct = "cancel2",
			underattack = "warning1",
			cant = {
				[1] = "cantdo4",
			},
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			ok = {
				[1] = "tcormove",
			},
			select = {
				[1] = "tcorsel",
			},
		},
	},
}
