# multistage builds

Sometimes you might have a really long dockerfile, where several instructions are to do with downloading a bunch of libraries in order to compile a single binary file, which is the end product needed. In that scenario, you will end up with a big image, because of all the library files downloaded. 

To keep your image as lightweight as possible, you can break your dockerfile into two seperate images:

```bash
FROM alpine as compiler_phase
{install a bunch of library packages and}
{run the compiler}


FROM alpine
COPY --from=compiler_phase /path/to/compiled/binary /path/to/location/in/this/image
```