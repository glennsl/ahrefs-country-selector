const path = require("path")
const outputDir = path.join(__dirname, "build/")

module.exports = env => ({
  entry: "./src/main.bs.js",
  mode: env.production ? "production" : "development",
  devtool: "source-map",
  output: {
    path: outputDir,
    filename: "main.js"
  }
})
