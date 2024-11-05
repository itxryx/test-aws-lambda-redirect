exports.handler = async (event) => {
  const targetUrl = process.env.TARGET_URL;

  if (!targetUrl) {
    return {
      statusCode: 500,
      body: "Error: TARGET_URL is not set.",
    };
  }

  return {
    statusCode: 301,
    headers: {
      Location: targetUrl,
    },
    body: '',
  };
};