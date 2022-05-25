import { randomUUID } from "crypto"
import puppeteer, { BrowserConnectOptions, BrowserLaunchArgumentOptions, HTTPResponse, LaunchOptions, PDFOptions, Product, WaitForOptions } from "puppeteer"
import { APP_TMP_PATH, APP_URL } from "./constants"

export type Mode = "html" | "pdf" | "screenshot" | "evaluate"

type ILaunchOptions = LaunchOptions & BrowserLaunchArgumentOptions & BrowserConnectOptions & {
  product?: Product;
  extraPrefsFirefox?: Record<string, unknown>
}
export type Input = {
  mode?: Mode
  url?: string
  content?: string
  evaluate?: any
  launchOptions?: ILaunchOptions
  waitForOptions?: WaitForOptions
  PDFOptions?: PDFOptions
}

export type Output = {
  pdf?: string | Buffer
  text?: string

}

export const launch = async (input: Input): Promise<Output> => {
  const output: Output = {}
  const launchOptions = prepareLaunchOptions(input.launchOptions)
  const browser = await puppeteer.launch(launchOptions);
  const page = await browser.newPage();
  let response: HTTPResponse | null = null

  console.log('input', input);

  if (input.url) {
    response = await page.goto(input.url, input.waitForOptions)
  }
  if (input.content) {
    await page.setContent(input.content, input.waitForOptions);
  }

  if (input.mode === 'html') {
    output.text = await response.text()
  }

  if (input.mode === 'pdf') {
    input.PDFOptions = preparePDFOptions(input.PDFOptions)
    const pdf = await page.pdf(input.PDFOptions);
    if (input.PDFOptions.path) {
      output.pdf = getUrl(input.PDFOptions.path)
    } else {
      output.pdf = pdf
    }
  }

  await browser.close();

  return output

}

function prepareLaunchOptions(options: ILaunchOptions): LaunchOptions {
  if (!options) {
    options = {
      args: []
    }
  }
  if (options.args) {
    options.args = [...options.args, '--no-sandbox', '--disable-setuid-sandbox']
  }
  return options
}

function preparePDFOptions(options?: PDFOptions): PDFOptions {
  if (!options) {
    options = {}
  }
  if (options.path) {
    options.path = `${getPath(options.path)}`
  }
  return options
}

function getPath(path: string): string {
  const filename = (path.indexOf('/') === -1)
    ? path
    : generateFilename('pdf')

  return APP_TMP_PATH + "/" + filename
}

function generateFilename(ext: string): string {
  return randomUUID() + '.' + ext
}

function getUrl(filePath: string) {
  return filePath.replace(APP_TMP_PATH, APP_URL)
}