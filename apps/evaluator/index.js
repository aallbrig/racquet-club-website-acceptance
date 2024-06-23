import puppeteer from 'puppeteer';
import validator from 'validator';

async function generateReport(targetUrl) {
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
    await crawl(targetUrl, page, report);
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

async function crawl(targetUrl, page, report, additionalTasks = []) {
  const targetUrlObj = new URL(targetUrl);
  if (report.visited.includes(targetUrlObj.href)) {
    return;
  }

  report.visited.push(targetUrlObj.href);
  report[targetUrlObj.href] = {};
  await page.goto(targetUrlObj.href, { waitUntil: 'networkidle0' });
  report[targetUrlObj.href].title = await page.title();
  report[targetUrlObj.href].internalLinks = [];
  report[targetUrlObj.href].externalLinks = [];

  const links = await page.$$eval('a', as => as.map(a => a.href));
  const linkUrls = links.map(link => {
    const linkUrl = new URL(link);
    linkUrl.hash = ""; // removes hash so that example.com/ and example.com/# are considered the same
    return linkUrl;
  });

  const uniqueInternalLinks = new Set();
  const uniqueExternalLinks = new Set();

  for (const linkUrl of linkUrls) {
    if (linkUrl.hostname === targetUrlObj.hostname) {
      uniqueInternalLinks.add(linkUrl.href);
    } else {
      uniqueExternalLinks.add(linkUrl.href);
    }
  }

  report[targetUrlObj.href].internalLinks = Array.from(uniqueInternalLinks)
    .map(href => new URL(href))
    .sort((a, b) => a.href.localeCompare(b.href));
  report[targetUrlObj.href].externalLinks = Array.from(uniqueExternalLinks)
    .map(href => new URL(href))
    .sort((a, b) => a.href.localeCompare(b.href));

  additionalTasks.forEach(additionalTask => additionalTask(page));

  for (const link of report[targetUrlObj.href].internalLinks) {
    await crawl(link.href, page, report);
  }
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
  const reportPromise = generateReport(new URL(targetUrl));
  reportPromise.then((report) => {
    console.log(JSON.stringify(report, null, 2));
    process.exit(0);
  });
}

main();
