const HtmlInlineScriptPlugin = require("html-inline-script-webpack-plugin");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const { merge } = require("webpack-merge");
const common = require("./webpack.common");

module.exports = merge(common, {
  mode: "development",
  devtool: "inline-source-map",
  plugins: [
    new HtmlWebpackPlugin({
      title: "ACG Homework",
      meta: [
        {
          viewport: "width=device-width, initial-scale=1",
          name: "author",
          content: "Takuto Itoi (1W183011-7)",
        },
      ],
      inlineSource: ".(glsl|ts|js|css)$",
      minify: false,
    }),
    new HtmlInlineScriptPlugin(),
  ],
});
