var resolve = require('path').resolve;
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var CopyWebpackPlugin = require('copy-webpack-plugin');

var env = process.env.MIX_ENV || 'dev';
var prod = env === 'prod';
var plugins = [
  new ExtractTextPlugin('css/app.css'),
  new CopyWebpackPlugin([
    { from: './static' },
    {
      from: './../deps/phoenix_html/priv/static/phoenix_html.js',
      to: 'js/phoenix_html.js',
    },
    {
      from: './../deps/phoenix/priv/static/phoenix.js',
      to: 'js/phoenix.js',
    },
  ]),
];

module.exports = {
  entry: ['./js/app.js', './css/app.css'],
  output: {
    path: require('path').resolve('./../priv/static'),
    filename: 'js/app.js',
  },
  resolve: {
    modules: ['node_modules'],
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules|deps/,
        loader: 'babel-loader',
        options: {
          presets: ['es2015'],
        },
      },
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract({ fallback: 'style-loader', use: 'css-loader' }),
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {
            cwd: resolve('./elm'),
          },
        },
      },
    ],
  },
  plugins: plugins,
};
