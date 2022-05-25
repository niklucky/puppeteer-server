import { randomUUID } from "crypto"
import puppeteer, { HTTPResponse, LaunchOptions, PDFOptions, WaitForOptions } from "puppeteer"
import { APP_TMP_PATH, APP_URL } from "./constants"

export type Mode = "html" | "pdf" | "screenshot" | "evaluate"

export type Input = {
  mode?: Mode
  url?: string
  content?: string
  evaluate?: any
  launchOptions?: LaunchOptions
  waitForOptions?: WaitForOptions
  PDFOptions?: PDFOptions
}

export type Output = {
  pdf?: string | Buffer
  text?: string

}

export const launch = async (input: Input): Promise<Output> => {
  const output: Output = {}

  const browser = await puppeteer.launch(input.launchOptions);
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