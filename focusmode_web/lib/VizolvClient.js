"use client";

import { Vizolv } from "vizolv";

export default function VizolvClient() {
  return (
    <>
      <Vizolv
        buttonPosition={{
          bottom: 20,
        }}
        heading={"100xdevs"}
        timestampRedirectLink={({ start, video, text, _id }) => {
          return `/video/${video._id}?start=${start}&text=${text}&_id=${_id}`;
        }}
      />
    </>
  );
}
