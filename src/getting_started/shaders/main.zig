const std = @import("std");
const glfw = @import("glfw");
const gl = @import("gl");
const Shader = @import("./Shader.zig");
const WindowSize = struct {
    pub const width: u32 = 800;
    pub const height: u32 = 600;
};

pub fn main() !void {
    std.log.info("{s}", .{Shader.haha});

    // glfw: initialize and configure
    // ------------------------------
    if (!glfw.init(.{})) {
        std.log.err("GLFW initialization failed", .{});
        return;
    }
    defer glfw.terminate();

    // glfw window creation
    // --------------------
    const window = glfw.Window.create(WindowSize.width, WindowSize.height, "mach-glfw + zig-opengl", null, null, .{
        .opengl_profile = .opengl_core_profile,
        .context_version_major = 4,
        .context_version_minor = 1,
    }) orelse {
        std.log.err("GLFW Window creation failed", .{});
        return;
    };
    defer window.destroy();

    glfw.makeContextCurrent(window);
    glfw.Window.setFramebufferSizeCallback(window, framebuffer_size_callback);

    // Load all OpenGL function pointers
    // ---------------------------------------
    const proc: glfw.GLProc = undefined;
    try gl.load(proc, glGetProcAddress);

    // memory management
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var arena_allocator_state = std.heap.ArenaAllocator.init(allocator);
    defer arena_allocator_state.deinit();
    const arena_allocator = arena_allocator_state.allocator();

    // create shader program
    var shader_program: Shader = Shader.create(arena_allocator, "C:\\Users\\CraftLinks\\Documents\\GitHub\\craftlinks\\zig_learn_opengl\\src\\getting_started\\shaders\\shaders\\shader.vs", "C:\\Users\\CraftLinks\\Documents\\GitHub\\craftlinks\\zig_learn_opengl\\src\\getting_started\\shaders\\shaders\\shader.fs");

    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------
    const vertices = [_]f32{ 
        // Positions     // Colors
        -0.5, -0.5, 0.0, 1.0, 0.0, 0.0, 
         0.5, -0.5, 0.0, 0.0, 1.0, 0.0,
         0.0,  0.5, 0.0, 0.0, 0.0, 1.0,
    };
    var VBO: c_uint = undefined;
    var VAO: c_uint = undefined;

    gl.genVertexArrays(1, &VAO);
    defer gl.deleteVertexArrays(1, &VAO);

    gl.genBuffers(1, &VBO);
    defer gl.deleteBuffers(1, &VBO);

    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    gl.bindVertexArray(VAO);
    gl.bindBuffer(gl.ARRAY_BUFFER, VBO);
    // Fill our buffer with the vertex data
    gl.bufferData(gl.ARRAY_BUFFER, @sizeOf(f32) * vertices.len, &vertices, gl.STATIC_DRAW);

    // Specify and link our vertext attribute description
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);

    const offset: c_uint = 3 * @sizeOf(f32);
    const offset_ptr = &offset;
    gl.vertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), offset_ptr);
    gl.enableVertexAttribArray(1);

    while (!window.shouldClose()) {
        processInput(window);

        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT);
        shader_program.use();
        gl.bindVertexArray(VAO); // seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
        gl.drawArrays(gl.TRIANGLES, 0, 3);

        window.swapBuffers();
        glfw.pollEvents();
    }
}

fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.FunctionPointer {
    _ = p;
    return glfw.getProcAddress(proc);
}

fn framebuffer_size_callback(window: glfw.Window, width: u32, height: u32) void {
    _ = window;
    gl.viewport(0, 0, @intCast(c_int, width), @intCast(c_int, height));
}

fn processInput(window: glfw.Window) void {
    if (glfw.Window.getKey(window, glfw.Key.escape) == glfw.Action.press) {
        _ = glfw.Window.setShouldClose(window, true);
    }
}