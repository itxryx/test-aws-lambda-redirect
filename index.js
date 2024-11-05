exports.handler = async (event) => {
  return {
    statusCode: 301,
    headers: {
      Location: 'https://example.com',
    },
    body: '',
  };
};