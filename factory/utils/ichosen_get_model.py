from transformers import AutoModel
import torch


def auto_load_model(model_path):
    """
    Load models: on single GPU or multiple GPUs

    @author  iChosen Group
    @date    2023-11-06
    """
    model = AutoModel.from_pretrained(model_path, trust_remote_code=True)
    if torch.cuda.device_count() > 1:
        from accelerate import dispatch_model
        from accelerate.utils import infer_auto_device_map, get_balanced_memory

        if model._no_split_modules is None:
            raise ValueError("The model class needs to implement the `_no_split_modules` attribute.")

        kwargs = {"dtype": model.dtype, "no_split_module_classes": model._no_split_modules}
        max_memory = get_balanced_memory(model, **kwargs)

        # Make sure tied weights are tied before creating the device map.
        model.tie_weights()

        device_map = infer_auto_device_map(model, max_memory=max_memory, **kwargs)
        return dispatch_model(model, device_map)
    elif torch.cuda.device_count() == 1:
        return model.cuda()
    else:
        return model