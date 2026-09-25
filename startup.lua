print "Démarrage du bucheron sur la version 5.0-alpha, patientez..."
os.sleep(1)
local METIER = "Bucheron"
local SERVER_HOSTNAME = "bucheron_server"
shell.run(METIER, SERVER_HOSTNAME)
