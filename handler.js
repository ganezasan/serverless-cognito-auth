'use strict';

module.exports.hello = (event, context, callback) => {
  callback(null, { Message: 'Hello World!'});
};

module.exports.goodNight = (event, context, callback) => {
  callback(null, { Message: 'Good Night World!'});
};
