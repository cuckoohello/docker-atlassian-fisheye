#!/usr/bin/python3

from entrypoint_helpers import env, gen_cfg, gen_container_id, str2bool, start_app


RUN_USER = env['run_user']
RUN_GROUP = env['run_group']
FISHEYE_INSTALL_DIR = env['fisheye_install_dir']
FISHEYE_HOME = env['fisheye_inst']

gen_cfg('config.xml.j2', f'{FISHEYE_HOME}/config.xml', user=RUN_USER, group=RUN_GROUP, overwrite=False)

start_app(f"{FISHEYE_INSTALL_DIR}/bin/fisheyectl.sh run", FISHEYE_HOME, name='Fisheye Server')
