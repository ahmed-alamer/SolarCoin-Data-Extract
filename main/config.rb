#global
require 'json' #Rails JSON library
require 'date' #WTF Ruby?
require 'set' #WTF Ruy? Again!

#project
require '../main/io/data_file_handler'
require '../main/io/data_processor'
require '../main/io/logger'
require '../main/models/claimant'
require '../main/models/project'
require '../main/models/wallet'
require '../main/models/grant'

DATA_DIRECTORY = '/home/ahmed/solar-coin-data'

INPUT_DIRECTORY = "#{DATA_DIRECTORY}/input"
CLAIMS_DIRECTORY_REGEX = "#{INPUT_DIRECTORY}/claims/*.json"

OUTPUT_DIRECTORY = "#{DATA_DIRECTORY}/output"
