const { TMP_PATH = './tmp', HOST, PORT } = process.env

export const APP_TMP_PATH = TMP_PATH
export const APP_HOST = HOST || 'http:/localhost'
export const APP_PORT = PORT || 3000
export const APP_URL = APP_HOST + ":" + APP_PORT
