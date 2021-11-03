const HtmlWebpackPlugin = require("html-webpack-plugin");
const path = require("path");
const fs = require("fs");
const appDirectory = fs.realpathSync(process.cwd());

module.exports = (env) => {
  return {
    mode: "development",
    entry: path.resolve(appDirectory, "src/main.ts"),
    output: {
      filename: "bundle.js",
      path: path.resolve(appDirectory, "dist"),
      clean: true,
      publicPath: "auto",
    },
    module: {
      rules: [
        {
          test: /\.ts$/,
          use: "ts-loader",
          exclude: /node_modules/,
        },
        {
          test: /\.tsx?$/,
          use: "ts-loader",
          exclude: /node_modules/,
        },
        {
          test: /.glsl$/,
          use: "ts-shader-loader",
          exclude: /node_modules/,
        },
      ],
    },
    resolve: {
      extensions: [".ts", ".tsx", ".js"],
    },
    devServer: {
      host: "0.0.0.0",
      port: 8081,
      static: path.resolve(appDirectory, "dist"),
      hot: true,
      devMiddleware: {
        publicPath: "auto",
      },
    },
    plugins: [
      new HtmlWebpackPlugin({
        title: "ACG Homework",
        meta: [
          {
            viewport: "width=device-width, initial-scale=1",
            name: "takuto",
            content: "Takuto Itoi (1W183011-7)",
          },
        ],
        minify: false,
      }),
    ],
  };
};
