#pragma once
#include "mesh_app.h"

void draw_header(Canvas* canvas, ZeroMeshApp* app, const char* title);
void render_page(Canvas* canvas, ZeroMeshApp* app);   /* renders app->ui_mode */
void input_dispatch(InputEvent* e, ZeroMeshApp* app); /* handles a button event */
