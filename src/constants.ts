const { TMP_PATH = '/tmp', SERVER_URL, PORT, REQUEST_SIZE } = process.env

export const APP_TMP_PATH = TMP_PATH
export const APP_PORT = PORT || 3000
export const APP_URL = SERVER_URL || ''
export const APP_REQUEST_SIZE = REQUEST_SIZE || '20mb'
