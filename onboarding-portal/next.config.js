/** @type {import('next').NextConfig} */
const nextConfig = {
  async rewrites() {
    return [
      {
        source: "/api/registry/:path*",
        destination: "http://localhost:3030/:path*",
      },
      {
        source: "/api/gateway/:path*",
        destination: "http://localhost:4030/:path*",
      },
      {
        source: "/api/bap/:path*",
        destination: "http://localhost:8002/:path*",
      },
      {
        source: "/api/bpp/:path*",
        destination: "http://localhost:8001/:path*",
      },
    ];
  },
};

module.exports = nextConfig;
