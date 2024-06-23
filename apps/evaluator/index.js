import puppeteer from 'puppeteer';
import validator from 'validator';

async function evaluate(targetUrl) {
  const report = {
    visited: []
  };
  let browser;
  try {
    browser = await puppeteer.launch({
      headless: false,
      slowMo: 250
    });
    const page = await browser.newPage();
    await page.goto(targetUrl);
    if (report.visited.indexOf(targetUrl) === -1) {
      report.visited.push(targetUrl);
    }
  } catch (error) {
    console.error(`Failed to evaluate ${targetUrl}: ${error}`);
    process.exit(1);
  } finally {
    if (browser) {
      await browser.close();
    }
  }
  return report;
}

function usage() {
  console.log();
  console.log("Usage");
  console.log("-----");
  console.log("  $ node index.js https://www.example.com");
  console.log("  $ npm start -- https://www.example.com");
  console.log();
}

function isUrl(maybeUrl) {
  return validator.isURL(maybeUrl);
}

function main() {
  const targetUrl = process.argv[2];
  if (targetUrl == null) {
    console.error("missing url argument")
    usage();
    process.exit(1);
  }
  if (!isUrl(targetUrl)) {
    console.error("argument is not a valid URL")
    usage();
    process.exit(1);
  }
  const reportPromise = evaluate(targetUrl);
  reportPromise.then((report) => {
    console.log(report);
  });
}

main();
