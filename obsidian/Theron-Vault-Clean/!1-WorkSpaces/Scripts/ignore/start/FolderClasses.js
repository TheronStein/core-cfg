module.exports = start;


	.nav-folder-title[Data-Path^="!"].classList.add("navdir-Vault");
	.nav-folder-title[Data-Path^="0"].classList.add("navdir-Default");
	.nav-folder-title[Data-Path^="X"].classList.add("navdir-Personal");
	.nav-folder-title[Data-Path^="X"].classList.add("navdir-Mounts");	
}