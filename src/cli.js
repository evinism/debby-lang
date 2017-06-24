import program from 'commander';
import { parser } from './../build/parser';
import fs from 'fs';

export default function run(){
  let filePath;

  program
    .version('0.1.0')
    .arguments('[file]')
    .action(path => filePath = path)
    .parse(process.argv);

  let source;
  //console.log(parse);
  if (filePath){
    source = fs.readFileSync(filePath, "utf8");
  }

  //const parser = new Parser();
  const test = parser.parse(source);
  console.log(JSON.stringify(test, null, 2));
}
